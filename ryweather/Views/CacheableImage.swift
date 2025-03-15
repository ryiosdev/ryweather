//
//  CacheableImage.swift
//  ryweather
//
//  Created by Ryan Young on 3/5/25.
//

import SwiftUI
import SwiftData

fileprivate var memCache: [URL: Image] = [:]


@Model
class CachedImage {
    @Attribute(.unique) var url: URL
    @Attribute(.externalStorage) var imageData: Data
    
    init(url: URL, imageData: Data) {
        self.url = url
        self.imageData = imageData
    }
}

struct CacheableImage: View {
    @Environment(\.modelContext) var modelContext

    let url: URL
    
    @Query private var swCachedImages: [CachedImage]

    init(url: URL) {
        self.url = url
        
        let predicate = #Predicate<CachedImage> { $0.url == url }
        _swCachedImages = Query(filter: predicate)
    }
    
    var body: some View {
        if let swCachedImage = swCachedImages.first,
           let image = imageFrom(data: swCachedImage.imageData) {
            image
                .onAppear {
                    logger.debug("Reusing existing SwiftData image for : \(url.absoluteString)")
                }
        } else if let cachedImage = memCache[url] {
            cachedImage
                .onAppear {
                    logger.debug("Reusing existing memCache image for : \(url.absoluteString)")
                }
        } else {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .onAppear {
                            cache(image: image)
                        }
                } else if phase.error != nil {
                    EmptyView()
                    Image(systemName: "")
                } else {
                    ProgressView()
                }
            }
        }
    }
    
    private func imageFrom(data: Data) -> Image? {
#if os(macOS)
        if let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
#else // TODO: assuming this works for all other platforms.
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
#endif
        return nil
    }
    
    private func cache(image: Image) {
        //memCache[url] = image
        let imageRenderer = ImageRenderer(content: image)
        var data: Data?
#if os(macOS)
        if let nsImage = imageRenderer.nsImage {
            data = nsImage.tiffRepresentation // NOTE: saved as .tiff
        }
#else
        if let uiImage = imageRenderer.uiImage {
            data = uiImage.pngData() // NOTE: saved as .png
        }
#endif
        guard let data else {
            logger.error("unable to create data for image")
            return
        }
        
        let cachedImage = CachedImage(url: self.url, imageData: data)
        modelContext.insert(cachedImage)
        do {
            try modelContext.save()
        } catch {
            logger.error("Error saving cached image: \(error)")
        }
        logger.debug("Cached new image to SwiftData for : \(url.absoluteString)")
    }
}
