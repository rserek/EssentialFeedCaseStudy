//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Radosław Serek on 30/05/2023.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private struct InvalidImageDataError: Error { }

    private let view: View
    private let imageTransformator: (Data) -> Image?

    public init(view: View, imageTransformator: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformator = imageTransformator
    }
    
    public func didStartLoadingImage(for model: FeedImage) {
        view.display(.init(location: model.location,
                           description: model.description,
                           isLoading: true,
                           isRetryAvailable: false,
                           image: nil))
    }
    
    public func didFinishLoadingImageData(_ data: Data, for model: FeedImage) {
        let image = imageTransformator(data)
        view.display(.init(location: model.location,
                           description: model.description,
                           isLoading: false,
                           isRetryAvailable: image == nil,
                           image: image))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(.init(location: model.location,
                           description: model.description,
                           isLoading: false,
                           isRetryAvailable: true,
                           image: nil))
    }
}
