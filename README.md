## Series of posts about building Redux-like Single Source of Truth in SwiftUI.
Single source of truth eliminates tons of bugs produced by creating multiple states across the app. The main idea here is describing the whole app state by using a single struct or composition of structs. A single state for the whole app makes it easier to debug and inspect.

* [Redux-like state container in SwiftUI. Basics.](https://swiftwithmajid.com/2019/09/18/redux-like-state-container-in-swiftui/)
* [Redux-like state container in SwiftUI. Best practices.](https://swiftwithmajid.com/2019/09/25/redux-like-state-container-in-swiftui-part2/)
* [Redux-like state container in SwiftUI. Container Views.](https://swiftwithmajid.com/2019/10/02/redux-like-state-container-in-swiftui-part3/)

```swift
import Foundation
import Combine

typealias Reducer<State, Action, Environment> =
    (inout State, Action, Environment) -> AnyPublisher<Action, Never>?

final class Store<State, Action, Environment>: ObservableObject {
    @Published private(set) var state: State
    
    private let reducer: Reducer<State, Action, Environment>
    private let environment: Environment

    private var effectCancellables: Set<AnyCancellable> = []
    private var projectionCancellable: AnyCancellable?

    init(
        initialState: State,
        reducer: @escaping Reducer<State, Action, Environment>,
        environment: Environment
    ) {
        self.state = initialState
        self.reducer = reducer
        self.environment = environment
    }

    func send(_ action: Action) {
        guard let effect = reducer(&state, action, environment) else {
            return
        }

        var didComplete = false
        var cancellable: AnyCancellable?

        cancellable = effect
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self, weak cancellable] _ in
                    didComplete = true
                    cancellable.map { self?.effectCancellables.remove($0) }
                }, receiveValue: { [weak self] in self?.send($0) })
        if !didComplete, let cancellable = cancellable {
            effectCancellables.insert(cancellable)
        }
    }

    func projection<ProjectedState: Equatable, ProjectedAction>(
        projectState: @escaping (State) -> ProjectedState,
        projectAction: @escaping (ProjectedAction) -> Action
    ) -> Store<ProjectedState, ProjectedAction, Void> {
        let store = Store<ProjectedState, ProjectedAction, Void>(
            initialState: projectState(state),
            reducer: { _, action, _ in
                self.send(projectAction(action))
                return nil
        },
            environment: ()
        )

        store.projectionCancellable = $state
            .map(projectState)
            .removeDuplicates()
            .sink { [weak store] in store?.state = $0 }

        return store
    }
}

import SwiftUI

extension Store {
    func binding<Value>(
        for keyPath: KeyPath<State, Value>,
        toAction: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding<Value>(
            get: { self.state[keyPath: keyPath] },
            set: { self.send(toAction($0)) }
        )
    }
}
```
