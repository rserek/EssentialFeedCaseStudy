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
        let refreshController = FeedRefreshViewController(delegate: feedLoadingPresentationAdapter)
        let feedViewController = FeedViewController(refreshController: refreshController)
        let feedViewAdapter = FeedViewAdapter(controller: feedViewController, loader: imageLoader)
        let feedPresenter = FeedPresenter(loadingView: WeakRefVirtualProxy(refreshController), feedView: feedViewAdapter)
        feedLoadingPresentationAdapter.presenter = feedPresenter
        
        return feedViewController
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
            let viewModel = FeedImageViewModel(model: model,
                                               imageLoader: loader,
                                               imageTransformator: UIImage.init)
            return FeedImageCellController(viewModel: viewModel)
        }
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

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
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
