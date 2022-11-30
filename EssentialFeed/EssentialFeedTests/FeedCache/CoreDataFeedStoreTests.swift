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
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCash() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedValues() {
        let sut = makeSUT()

        assertThatInsertOverridesPreviouslyInsertedValues(on: sut)
    }
    
    func test_deleteCachedFeed_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteCacheFeedDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_deleteCachedFeed_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteCacheFeedHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_deleteCachedFeed_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteCacheFeedDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_deleteCachedFeed_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()

        assertThatDeleteCacheFeedEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()

        assertThatSideEffectsRunSerially(on: sut)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
