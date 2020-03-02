//
//  App.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 9/16/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//
import Foundation
import Combine

// For more information check "How To Control The World" - Stephen Celis
// https://vimeo.com/291588126
struct World {
    var service = GithubService()
}

enum AppAction {
    case setSearchResults(repos: [Repo])
    case search(query: String)
}

struct AppState {
    var searchResult: [Repo] = []
}

func appReducer(
    state: inout AppState,
    action: AppAction,
    environment: World
) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .setSearchResults(repos):
        state.searchResult = repos
    case let .search(query):
        return environment.service
            .searchPublisher(matching: query)
            .replaceError(with: [])
            .map { AppAction.setSearchResults(repos: $0) }
            .eraseToAnyPublisher()
    }
    return Empty().eraseToAnyPublisher()
}

typealias AppStore = Store<AppState, AppAction, World>
