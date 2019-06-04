//
//  RepoStore.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 6/5/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//

import SwiftUI
import Combine

class ReposStore: BindableObject {
    var willChange = PassthroughSubject<Void, Never>()

    @Published private(set) var repos: [Repo] = []

    private let service: GithubService
    private var searchCancellable: AnyCancellable?
    private var didChangeCancellable: AnyCancellable?

    init(service: GithubService) {
        self.service = service
        didChangeCancellable = $repos
            .map { _ in () }
            .receive(on: RunLoop.main)
            .subscribe(willChange)
    }

    func fetch(matching query: String) {
        searchCancellable = service
            .searchPublisher(matching: query)
            .replaceError(with: [])
            .assign(to: \.repos, on: self)
    }
}
