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
        
        expect(sut, toCompleteWithResult: .failure(retrievalError), when: {
            store.completeRetrievalWithError(retrievalError)
        })
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([]), when: {
            store.completeRetrievalWithNoCache()
        })
    }
    
    func test_load_deliversCachedImagesOnLessThenSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThenSevenDaysOldTimestamp = fixedCurrentDate.addingDays(-7).addingSeconds(1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWithResult: .success(feed.models), when: {
            store.completeRetrieval(with: feed.local, timestamp: lessThenSevenDaysOldTimestamp)
        })
    }

    func test_load_deliversNoImagesOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.addingDays(-7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWithResult: .success([]), when: {
            store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
        })
    }

    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.addingDays(-7).addingSeconds(-1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWithResult: .success([]), when: {
            store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)
        })
    }
    
    func test_load_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithError(anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }

    func test_load_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithNoCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }

    private func expect(_ sut: LocalFeedLoader, toCompleteWithResult expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = XCTestExpectation(description: "Wait for load completion")
        sut.load() { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedImageFeed), .success(receivedImageFeed)):
                XCTAssertEqual(expectedImageFeed, receivedImageFeed, file: file, line: line)
                
            case let (.failure(expectedError), .failure(receivedError)):
                XCTAssertEqual(expectedError as NSError, receivedError as NSError, file: file, line: line)

            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Invalid request", code: 400)
    }
    
    private func uniqueImage() -> FeedImage {
        return .init(id: UUID(), description: nil, location: nil, url: URL(string: "https://a-url.com")!)
    }

    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feed = [uniqueImage(), uniqueImage()]
        let localFeed = feed.map { LocalFeedImage(id: $0.id,
                                                   description: $0.description,
                                                   location: $0.location,
                                                   url: $0.url)}
        return (feed, localFeed)
    }
}

private extension Date {
    func addingDays(_ days: Int) -> Self {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func addingSeconds(_ seconds: TimeInterval) -> Self {
        return self + seconds
    }
}
