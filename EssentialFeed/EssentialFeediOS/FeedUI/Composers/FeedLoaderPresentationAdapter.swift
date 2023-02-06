//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 06/02/2023.
//

import EssentialFeed

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
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
