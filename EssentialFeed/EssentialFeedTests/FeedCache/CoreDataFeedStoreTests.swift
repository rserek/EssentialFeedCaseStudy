//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 23/11/2022.
//

import EssentialFeed
import XCTest

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCash() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyInsertedValues() {
        
    }
    
    func test_deleteCachedFeed_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_deleteCachedFeed_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_deleteCachedFeed_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_deleteCachedFeed_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CoreDataFeedStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
