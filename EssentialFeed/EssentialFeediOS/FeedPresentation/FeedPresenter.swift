//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 05/02/2023.
//

import EssentialFeed
import Foundation

final class FeedPresenter {
    private let loadingView: FeedLoadingView
    private let feedView: FeedView

    static var title: String {
        return NSLocalizedString("feed_view_title",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }
    
    init(loadingView: FeedLoadingView, feedView: FeedView) {
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    func didStartLoadingFeed() {
        if Thread.isMainThread {
            loadingView.display(FeedLoadingViewModel(isLoading: true))
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.didStartLoadingFeed()
            }
        }
    }
    
    func didFinishLoading(with feed: [FeedImage]) {
        if Thread.isMainThread {
            feedView.display(FeedViewModel(feed: feed))
            loadingView.display(FeedLoadingViewModel(isLoading: false))
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.didFinishLoading(with: feed)
            }
        }
    }
    
    func didFinishLoading(with error: Error) {
        if Thread.isMainThread {
            loadingView.display(FeedLoadingViewModel(isLoading: false))
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.didFinishLoading(with: error)
            }
        }
    }
}
