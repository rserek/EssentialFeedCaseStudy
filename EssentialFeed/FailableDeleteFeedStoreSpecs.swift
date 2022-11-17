//
//  FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 17/11/2022.
//

import EssentialFeed
import XCTest

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteCacheFeedDeliversFailureOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(feed: uniqueImageFeed().local, timestamp: Date(), with: sut)
        
        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
    }
    
    func assertThatDeleteCacheFeedHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(feed: uniqueImageFeed().local, timestamp: Date(), with: sut)
        
        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
}
