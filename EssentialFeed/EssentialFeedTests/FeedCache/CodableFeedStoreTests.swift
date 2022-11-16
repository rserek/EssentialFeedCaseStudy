//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 16/11/2022.
//

import EssentialFeed
import XCTest

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = XCTestExpectation(description: "Wait for retrieve completion")
        sut.retrieve { result in
            switch result {
            case .empty: break
                
            default:
                XCTFail("Expected empty, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
