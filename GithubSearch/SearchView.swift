//
//  ContentView.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 6/4/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//
import SwiftUI
import Combine

struct LoadableImage: View {
    let url: URL

    @State private var uiImage: UIImage? = nil

    var body: some View {
        if let image = uiImage {
            return AnyView(Image(uiImage: image).resizable())
        } else {
            return AnyView(Image(systemName: "photo").onAppear(perform: fetch))
        }
    }

    private func fetch() {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.uiImage = image
                }
            }
        }.resume()
    }
}

struct RepoRow: View {
    let repo: Repo

    var body: some View {
        HStack(alignment: .top) {
            LoadableImage(url: repo.owner.avatar)
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
