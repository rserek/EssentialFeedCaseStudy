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
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(refreshController: refreshController)
        
        refreshController.onRefresh = { [weak feedViewController] feed in
            feedViewController?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
        return feedViewController
    }

}
