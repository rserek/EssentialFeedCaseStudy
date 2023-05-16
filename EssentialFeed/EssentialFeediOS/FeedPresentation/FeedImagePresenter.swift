//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 05/02/2023.
//

import EssentialFeed
import Foundation

protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImagePresentableModel<Image>)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformator: (Data) -> Image?
    
    init(view: View, imageTransformator: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformator = imageTransformator
    }
        
    func didStartLoadingImage(for model: FeedImage) {
        view.display(.init(location: model.location,
                           description: model.description,
                           isLoading: true,
                           isRetryAvailable: false,
                           image: nil))
    }
    
    private struct InvalidImageDataError: Error { }
    
    func didFinishLoadingImageData(_ data: Data, for model: FeedImage) {
        guard let image = imageTransformator(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(.init(location: model.location,
                           description: model.description,
                           isLoading: false,
                           isRetryAvailable: false,
                           image: image))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(.init(location: model.location,
                           description: model.description,
                           isLoading: false,
                           isRetryAvailable: true,
                           image: nil))
    }
}
