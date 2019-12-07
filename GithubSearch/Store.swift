//
//  Store.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 9/16/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//
import SwiftUI
import Combine

struct Effect<Action> {
    let publisher: AnyPublisher<Action, Never>
}

final class Store<State, Action>: ObservableObject {
    typealias Reducer = (inout State, Action) -> Void

    @Published private(set) var state: State

    private let reducer: Reducer
    private var cancellables: Set<AnyCancellable> = []

    init(initialState: State, reducer: @escaping Reducer) {
        self.state = initialState
        self.reducer = reducer
    }

    func send(_ action: Action) {
        reducer(&state, action)
    }

    func send(_ effect: Effect<Action>) {
        var cancellable: AnyCancellable?
        var didComplete = false

        cancellable = effect
            .publisher
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
