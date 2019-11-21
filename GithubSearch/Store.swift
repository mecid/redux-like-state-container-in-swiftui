import SwiftUI
import Combine

protocol Effect {
    associatedtype Action
    func mapToAction() -> AnyPublisher<Action, Never>
}

struct Reducer<State, Action> {
    let reduce: (inout State, Action) -> Void
}

final class Store<State, Action>: ObservableObject {
    @Published private(set) var state: State

    private let reducer: Reducer<State, Action>
    private var cancellables: Set<AnyCancellable> = []

    init(initialState: State, reducer: Reducer<State, Action>) {
        self.state = initialState
        self.reducer = reducer
    }

    func send(_ action: Action) {
        reducer.reduce(&state, action)
    }

    func send<E: Effect>(_ effect: E) where E.Action == Action {
        var cancellable: AnyCancellable?
        var didComplete = false

        cancellable = effect
            .mapToAction()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in
                    didComplete = true
                    if let effectCancellable = cancellable {
                        self?.cancellables.remove(effectCancellable)
                    }
                }, receiveValue: send)

        if !didComplete, let effectCancellable = cancellable {
            cancellables.insert(effectCancellable)
        }
    }
}

extension Store {
    func binding<Value>(
        for keyPath: KeyPath<State, Value>,
        _ action: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding<Value>(
            get: { self.state[keyPath: keyPath] },
            set: { self.send(action($0)) }
        )
    }
}
