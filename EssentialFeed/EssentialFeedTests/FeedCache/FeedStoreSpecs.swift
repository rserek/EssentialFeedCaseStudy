//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 17/11/2022.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCash()
    
    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertedValues()

    func test_deleteCachedFeed_deliversNoErrorOnEmptyCache()
    func test_deleteCachedFeed_hasNoSideEffectsOnEmptyCache()
    func test_deleteCachedFeed_deliversNoErrorOnNonEmptyCache()
    func test_deleteCachedFeed_emptiesPreviouslyInsertedCache()

    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnRetrievalError()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversFailureOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_deleteCacheFeed_deliversFailureOnDeletionError()
    func test_deleteCacheFeed_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStore = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
