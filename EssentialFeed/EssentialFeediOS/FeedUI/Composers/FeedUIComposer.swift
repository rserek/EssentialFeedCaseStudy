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
        let feedPresenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: feedPresenter)
        let feedViewController = FeedViewController(refreshController: refreshController)
        feedPresenter.feedView = FeedViewAdapter(controller: feedViewController, loader: imageLoader)
        feedPresenter.loadingView = WeakRefVirtualProxy(refreshController)

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
