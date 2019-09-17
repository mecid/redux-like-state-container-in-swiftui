//
//  App.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 9/16/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//

import Foundation
import Combine

enum AppMutation {
    case searchResults(repos: [Repo])
}

enum AppAction: Action {
    case search(query: String)

    func mapToMutation() -> AnyPublisher<AppMutation, Never> {
        switch self {
        case let .search(query):
            return dependencies.githubService
                .searchPublisher(matching: query)
                .replaceError(with: [])
                .map { AppMutation.searchResults(repos: $0) }
                .eraseToAnyPublisher()
        }
    }
}

struct AppState {
    var searchResult: [Repo] = []
}

let appReducer: Reducer<AppState, AppMutation> = { state, mutation in
    switch mutation {
    case let .searchResults(repos):
        state.searchResult = repos
    }
}
