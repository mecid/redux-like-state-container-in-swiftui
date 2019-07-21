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
                    .lineLimit(nil)
            }
        }
    }
}

struct SearchView : View {
    @EnvironmentObject var store: ReposStore
    @State private var query: String = "Swift"

    var body: some View {
        NavigationView {
            List {
                TextField("type something...", text: $query, onCommit: fetch)

                if store.repos.isEmpty {
                    Text("Loading...")
                } else {
                    ForEach(store.repos) { repo in
                        NavigationLink(destination: RepoRow(repo: repo)) {
                            RepoRow(repo: repo)
                        }
                    }
                }
            }
                .onAppear(perform: fetch)
                .navigationBarTitle(Text("Search"))
        }
    }

    private func fetch() {
        store.fetch(matching: query)
    }
}
