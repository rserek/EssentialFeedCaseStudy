//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 30/05/2023.
//

import XCTest

final class FeedImagePresenter {
    init(view: Any) {
        
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt64 = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        
        return (sut, view)
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
