//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 11/11/2022.
//

import EssentialFeed
import XCTest

class LocalFeedLoader {
    let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCacheFeedCallsCount: Int = 0
    
    func deleteCachedFeed() {
        deleteCacheFeedCallsCount += 1
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCacheFeedCallsCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)

        XCTAssertEqual(store.deleteCacheFeedCallsCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)

        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        return .init(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://a-url.com")!)
    }
}
