//
//  LoadFeedFromCacheUseCase.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 14/11/2022.
//

import EssentialFeed
import XCTest

class LoadFeedFromCacheUseCase: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        let exp = XCTestExpectation(description: "Wait for load completion")
        var receivedError: Error?
        sut.load() { result in
            switch result {
            case .failure(let error):
                receivedError = error
                
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeRetrievalWithError(retrievalError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as? NSError, retrievalError)
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        let exp = XCTestExpectation(description: "Wait for load completion")
        var receivedImages: [FeedImage] = []
        sut.load() { result in
            switch result {
            case .success(let images):
                receivedImages = images
                
            case .failure:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeRetrievalWithNoCache()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedImages, [])
    }

    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "Invalid request", code: 400)
    }
}
