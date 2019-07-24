//
//  RepoStore.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 6/5/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//
import Foundation
import Combine

class ReposStore: ObservableObject {
    @Published private(set) var repos: [Repo] = []

    private let service: GithubService
    private var searchCancellable: AnyCancellable?

    init(service: GithubService) {
        self.service = service
    }

    func fetch(matching query: String) {
        searchCancellable = service
            .searchPublisher(matching: query)
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.repos, on: self)
    }
}
