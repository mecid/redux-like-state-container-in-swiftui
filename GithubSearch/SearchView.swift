//
//  ContentView.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 6/4/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//
import SwiftUI
import Combine

struct RepoRow: View {
    let repo: Repo

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "photo") // placeholder
                .fetchingRemoteImage(from: repo.owner.avatar)
                .frame(width: 44, height: 44)
            VStack(alignment: .leading) {
                Text(repo.name)
                    .font(.headline)
                Text(repo.description ?? "")
                    .font(.subheadline)
            }
        }
    }
}

struct SearchContainerView: View {
    @EnvironmentObject var store: ReposStore
    @State private var query: String = "Swift"

    var body: some View {
        SearchView(query: $query, repos: store.repos, onCommit: fetch)
            .onAppear(perform: fetch)
    }

    private func fetch() {
        store.fetch(matching: query)
    }
}

struct SearchView : View {
    @Binding var query: String
    let repos: [Repo]
    let onCommit: () -> Void

    var body: some View {
        NavigationView {
            List {
                TextField("Type something", text: $query, onCommit: onCommit)

                if repos.isEmpty {
                    Text("Loading...")
                } else {
                    ForEach(repos) { repo in
                        NavigationLink(
                            destination: Details(repo: repo)
                                .environmentObject(ReposStore(service: .init()))
                    ) {
                            RepoRow(repo: repo)
                        }
                    }
                }
            }.navigationBarTitle(Text("Search"))
        }
    }
}

struct Details: View {
    @EnvironmentObject var store: ReposStore
    @State private var showSimilar = true
    @State private var showSimilar1 = true
    let repo: Repo

    var body: some View {
        List {
            Text(repo.name).bold()
            Toggle("show similar", isOn: $showSimilar)
            if showSimilar {
                ForEach(store.repos) { repo in
                    Text(repo.name)
                }
            }
        }.onAppear(perform: { self.store.fetch(matching: self.repo.name) })
    }
}
