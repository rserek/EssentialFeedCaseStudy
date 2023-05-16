//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 05/02/2023.
//

import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

struct FeedErrorViewModel {
    let message: String?
}

struct FeedViewModel {
    let feed: [FeedImage]
}
