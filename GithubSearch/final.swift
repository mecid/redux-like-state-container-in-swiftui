//
//  ContentView.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 6/4/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//

import SwiftUI
import Combine

struct FavoritesView : View {
    @EnvironmentObject var store: ReposStore

    var body: some View {
        NavigationView {
            List {
                ForEach(store.repos) { repo in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(repo.name)
                                .font(.headline)
                            Text(repo.description ?? "")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Favorites"))
            .onAppear(perform: fetch)
        }
    }

    private func fetch() {
        store.fetchFavorites()
    }
}
