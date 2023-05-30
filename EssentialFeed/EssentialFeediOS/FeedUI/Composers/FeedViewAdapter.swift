//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 06/02/2023.
//

import EssentialFeed
import UIKit

final class FeedViewAdapter: FeedView {
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
