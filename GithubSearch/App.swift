//
//  App.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 9/16/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//

import Foundation
import Combine

enum AppSideEffect: Effect {
    case search(query: String)

    func mapToAction() -> AnyPublisher<AppAction, Never> {
        switch self {
        case let .search(query):
            return Current.githubService
                .searchPublisher(matching: query)
                .replaceError(with: [])
                .map { AppAction.setSearchResults(repos: $0) }
                .eraseToAnyPublisher()
        }
    }
}

enum AppAction {
    case setSearchResults(repos: [Repo])
}

struct AppState {
    var searchResult: [Repo] = []
}

let appReducer: Reducer<AppState, AppAction> = Reducer { state, action in
    switch action {
    case let .setSearchResults(repos):
        state.searchResult = repos
    }
}
