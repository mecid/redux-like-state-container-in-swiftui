## Series of posts about building Redux-like Single Source of Truth in SwiftUI.
Single source of truth eliminates tons of bugs produced by creating multiple states across the app. The main idea here is describing the whole app state by using a single struct or composition of structs. A single state for the whole app makes it easier to debug and inspect.

* [Redux-like state container in SwiftUI. Basics.](https://swiftwithmajid.com/2019/09/18/redux-like-state-container-in-swiftui/)
* [Redux-like state container in SwiftUI. Best practices.](https://swiftwithmajid.com/2019/09/25/redux-like-state-container-in-swiftui-part2/)
* [Redux-like state container in SwiftUI. Container Views.](https://swiftwithmajid.com/2019/10/02/redux-like-state-container-in-swiftui-part3/)

```swift
import Foundation
import Combine

typealias Reducer<State, Action> = (inout State, Action) -> Void

func combine<State, Action>(_ reducers: Reducer<State, Action>...) -> Reducer<State, Action> {
    return { state, action in
        reducers.forEach { $0(&state, action) }
    }
}

func lift<ViewState, State, ViewAction, Action>(
    _ reducer: @escaping Reducer<ViewState, ViewAction>,
    keyPath: WritableKeyPath<State, ViewState>,
    transform: @escaping (Action) -> ViewAction?
) -> Reducer<State, Action> {
    return { state, action in
        if let localAction = transform(action) {
            reducer(&state[keyPath: keyPath], localAction)
        }
    }
}

final class Store<State, Action>: ObservableObject {
    typealias Effect = AnyPublisher<Action, Never>

    @Published private(set) var state: State

    private let reducer: Reducer<State, Action>
    private var cancellables: Set<AnyCancellable> = []
    private var viewCancellable: AnyCancellable?

    init(initialState: State, reducer: @escaping Reducer<State, Action>) {
        self.state = initialState
        self.reducer = reducer
    }

    func send(_ action: Action) {
        reducer(&state, action)
    }

    func send(_ effect: Effect){
        var didComplete = false
        var cancellable: AnyCancellable?
        cancellable = effect
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                didComplete = true
                if let cancellable = cancellable {
                    self?.cancellables.remove(cancellable)
                }
            }, receiveValue: send)
        if !didComplete, let cancellable = cancellable {
            cancellables.insert(cancellable)
        }
    }
}

extension Store {
    func view<ViewState, ViewAction>(
        state toLocalState: @escaping (State) -> ViewState,
        action toGlobalAction: @escaping (ViewAction) -> Action
    ) -> Store<ViewState, ViewAction> {
        let viewStore = Store<ViewState, ViewAction>(
            initialState: toLocalState(state)
        ) { state, action in
            self.send(toGlobalAction(action))
        }
        viewStore.viewCancellable = $state
            .map(toLocalState)
            .assign(to: \.state, on: viewStore)
        return viewStore
    }
}

import SwiftUI

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
```
