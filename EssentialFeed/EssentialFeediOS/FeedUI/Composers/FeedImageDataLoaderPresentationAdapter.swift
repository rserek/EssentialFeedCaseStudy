//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 06/02/2023.
//

import EssentialFeed

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?

    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func didRequestImage() {
        presenter?.didStartLoadingImage(for: model)
        
        task = self.imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }

    private func handle(_ result: FeedImageDataLoader.Result) {
        switch result {
        case let .success(imageData):
            presenter?.didFinishLoadingImageData(imageData, for: model)
            
        case let .failure(error):
            presenter?.didFinishLoadingImageData(with: error, for: model)
        }
    }

    func preload() {
        didRequestImage()
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
