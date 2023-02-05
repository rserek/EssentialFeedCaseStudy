//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 04/02/2023.
//

import EssentialFeed
import Foundation

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformator: (Data) -> Image?
    
    private var task: FeedImageDataLoaderTask?

    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformator: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformator = imageTransformator
    }
    
    var location: String? {
        return model.location
    }
    
    var isLocationHidden: Bool {
        return location == nil
    }

    var description: String? {
        return model.description
    }
    
    var onImageLoad: Observer<Image?>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onAllowRetryingStateChange: Observer<Bool>?
    
    func loadFeedImage() {
        onImageLoadingStateChange?(true)
        onImageLoad?(nil)
        onAllowRetryingStateChange?(false)
        
        task = self.imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        let data = try? result.get()
        let image = data.flatMap(imageTransformator) ?? nil
        onImageLoad?(image)
        onAllowRetryingStateChange?(image == nil)
        onImageLoadingStateChange?(false)
    }
    
    func preload() {
        task = imageLoader.loadImageData(from: model.url) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
