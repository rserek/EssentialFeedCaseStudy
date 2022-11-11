//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 11/11/2022.
//

import XCTest

class LocalFeedLoader {
    let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
}

class FeedStore {
    var deleteCacheFeedCallsCount: Int = 0
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCacheFeedCallsCount, 0)
    }
}
