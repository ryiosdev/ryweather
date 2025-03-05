//
//  CacheableImage.swift
//  ryweather
//
//  Created by Ryan Young on 3/5/25.
//

import SwiftUI

fileprivate var cache: [URL: Image] = [:]

struct CacheableImage: View {
    let url: URL
        
    var body: some View {
        if let cachedImage = cache[url] {
            cachedImage
                .onAppear {
                    logger.debug("Reusing existing image for : \(url.absoluteString)")
                }
        } else {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .onAppear {
                            cache[url] = image
                            logger.debug("Cached new image for : \(url.absoluteString)")
                        }
                } else if phase.error != nil {
                    EmptyView()
                } else {
                    ProgressView()
                }
            }
        }
    }
}
