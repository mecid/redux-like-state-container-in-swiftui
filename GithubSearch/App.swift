//
//  App.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 9/16/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//
import Foundation
import Combine

func search(query: String) -> AnyPublisher<AppAction, Never> {
    Current.searchRepos(query)
        .replaceError(with: [])
        .map { AppAction.setSearchResults(repos: $0) }
        .eraseToAnyPublisher()
}

enum AppAction {
    case setSearchResults(repos: [Repo])
}

struct AppState {
    var searchResult: [Repo] = []
}

func appReducer(state: inout AppState, action: AppAction) {
    switch action {
    case let .setSearchResults(repos):
        state.searchResult = repos
    }
}
