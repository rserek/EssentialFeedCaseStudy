//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 30/05/2023.
//

import XCTest

final class FeedPresenter {
    init(view: Any) {
        
    }
}

final class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
                
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt64 = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        
        return (sut, view)
    }
    private final class ViewSpy {
        let messages = [Any]()
    }
}
