//
//  RemoteImageModifier.swift
//  GithubSearch
//
//  Created by Majid Jabrayilov on 7/21/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//

import class Kingfisher.KingfisherManager
import SwiftUI

extension Image {
    func fetchingRemoteImage(from url: URL) -> some View {
        ModifiedContent(content: self, modifier: RemoteImageModifier(url: url))
    }
}

struct RemoteImageModifier: ViewModifier {
    let url: URL
    @State private var fetchedImage: UIImage? = nil

    func body(content: Content) -> some View {
        if let image = fetchedImage {
            return Image(uiImage: image)
                .resizable()
                .eraseToAnyView()
        }

        return content
            .onAppear(perform: fetch)
            .eraseToAnyView()
    }

    private func fetch() {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            self.fetchedImage = try? result.get().image
        }
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}
