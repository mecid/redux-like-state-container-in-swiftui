//
//  Redux.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 9/16/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//
import Foundation
import Combine

protocol Action {
    associatedtype Mutation
    func mapToMutation() -> AnyPublisher<Mutation, Never>
}

typealias Reducer<State, Mutation> = (inout State, Mutation) -> Void

final class Store<AppState, AppAction: Action>: ObservableObject {
    @Published private(set) var state: AppState

    private let appReducer: Reducer<AppState, AppAction.Mutation>
    private var cancellables: Set<AnyCancellable> = []

    init(
        initialState: AppState,
        appReducer: @escaping Reducer<AppState, AppAction.Mutation>
    ) {
        self.state = initialState
        self.appReducer = appReducer
    }

    func send(_ action: AppAction) {
        action
            .mapToMutation()
            .receive(on: DispatchQueue.main)
            .sink { self.appReducer(&self.state, $0) }
            .store(in: &cancellables)
    }
}
