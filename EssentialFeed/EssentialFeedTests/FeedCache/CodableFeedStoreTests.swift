//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 16/11/2022.
//

import EssentialFeed
import XCTest

final class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert(feed: feed, timestamp: timestamp, with: sut)

        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCash() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert(feed: feed, timestamp: timestamp, with: sut)
        
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let insertionError = insert(feed: uniqueImageFeed().local, timestamp: Date(), with: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert(feed: uniqueImageFeed().local, timestamp: Date(), with: sut)

        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let secondInsertionError = insert(feed: latestFeed, timestamp: latestTimestamp, with: sut)
        XCTAssertNil(secondInsertionError, "Expected to override cache successfully")
    }
    
    func test_insert_overridesPreviouslyInsertedValues() {
        let sut = makeSUT()
        insert(feed: uniqueImageFeed().local, timestamp: Date(), with: sut)

        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        insert(feed: latestFeed, timestamp: latestTimestamp, with: sut)

        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversFailureOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert(feed: feed, timestamp: timestamp, with: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert(feed: feed, timestamp: timestamp, with: sut)
        
        expect(sut, toRetrieve: .empty)
    }
        
    func test_deleteCachedFeed_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func test_deleteCachedFeed_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }

    func test_deleteCachedFeed_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert(feed: uniqueImageFeed().local, timestamp: Date(), with: sut)
             
        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    }

    func test_deleteCachedFeed_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert(feed: uniqueImageFeed().local, timestamp: Date(), with: sut)
             
        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty)
    }

    func test_deleteCacheFeed_deliversFailureOnDeletionError() {
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        insert(feed: uniqueImageFeed().local, timestamp: Date(), with: sut)
        
        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    func test_deleteCacheFeed_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        insert(feed: uniqueImageFeed().local, timestamp: Date(), with: sut)
        
        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        var completedOperationsInOrder: [XCTestExpectation] = []
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    @discardableResult
    private func insert(feed: [LocalFeedImage], timestamp: Date, with sut: FeedStore) -> Error? {
        let exp = XCTestExpectation(description: "Wait for retrieve completion")
        var receivedError: Error?
        sut.insert(feed, timestamp: timestamp) { insertionError in
            receivedError = insertionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedError
    }
    
    @discardableResult
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = XCTestExpectation(description: "Wait for delete completion")
        
        var deletionError: Error?
        sut.deleteCachedFeed { error in
            deletionError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)

        return deletionError
    }
    
    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = XCTestExpectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
                
            case (.empty, .empty),
                (.failure, .failure):
                break
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got  \(retrievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func noDeletePermissionURL() -> URL {
      return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
}
