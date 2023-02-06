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
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: MainQueueDisptachDecorator(decoratee: feedLoader))
        
        let feedViewController = FeedUIComposer.makeWith(delegate: presentationAdapter, title: FeedPresenter.title)

        presentationAdapter.presenter = FeedPresenter(
            loadingView: WeakRefVirtualProxy(feedViewController),
            feedView: FeedViewAdapter(controller: feedViewController, loader: MainQueueDisptachDecorator(decoratee: imageLoader))
        )
                
        return feedViewController
    }
    
    private static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.delegate = delegate
        feedViewController.title = title

        return feedViewController
    }
}
