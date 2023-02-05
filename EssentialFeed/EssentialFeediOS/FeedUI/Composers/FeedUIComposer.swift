//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 04/02/2023.
//

import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() { }
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedLoadingPresentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.delegate = feedLoadingPresentationAdapter
        feedViewController.title = FeedPresenter.title
        
        let feedViewAdapter = FeedViewAdapter(controller: feedViewController, loader: imageLoader)
        let feedPresenter = FeedPresenter(loadingView: WeakRefVirtualProxy(feedViewController), feedView: feedViewAdapter)
        feedLoadingPresentationAdapter.presenter = feedPresenter
        
        return feedViewController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T? = nil) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ viewModel: FeedImagePresentableModel<UIImage>) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: loader)
            let view = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view),
                                                   imageTransformator: UIImage.init)
            return view
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak presenter] result in
            switch result {
            case let .success(feed):
                presenter?.didFinishLoading(with: feed)
            case let .failure(error):
                presenter?.didFinishLoading(with: error)
            }
        }
    }
}

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
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
