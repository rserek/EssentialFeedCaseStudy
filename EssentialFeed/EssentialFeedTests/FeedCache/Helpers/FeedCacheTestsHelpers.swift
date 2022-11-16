//
//  FeedCacheTestsHelpers.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 15/11/2022.
//

import EssentialFeed
import Foundation

func uniqueImage() -> FeedImage {
    return .init(id: UUID(), description: nil, location: nil, url: URL(string: "https://a-url.com")!)
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let feed = [uniqueImage(), uniqueImage()]
    let localFeed = feed.map { LocalFeedImage(id: $0.id,
                                              description: $0.description,
                                              location: $0.location,
                                              url: $0.url)}
    return (feed, localFeed)
}

extension Date {
    private var maxCacheAgeInDays: Int { 7 }
    
    func minusFeedCacheMaxAge() -> Self {
        return addingDays(-maxCacheAgeInDays)
    }
    
    func addingDays(_ days: Int) -> Self {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func addingSeconds(_ seconds: TimeInterval) -> Self {
        return self + seconds
    }
}
