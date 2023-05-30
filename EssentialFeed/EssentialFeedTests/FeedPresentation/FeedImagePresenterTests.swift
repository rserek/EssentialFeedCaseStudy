//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 30/05/2023.
//

import EssentialFeed
import XCTest

struct FeedImageViewModel {
    let location: String?
    let description: String?
    let isLoading: Bool
    let isRetryAvailable: Bool
    let image: Any?
    
    var isLocationHidden: Bool {
        return location == nil
    }
}

protocol FeedImageView {
    func display(_ viewModel: FeedImageViewModel)
}

final class FeedImagePresenter<View: FeedImageView> {
    private let view: View

    init(view: View) {
        self.view = view
    }
    
    func didStartLoadingImage(for model: FeedImage) {
        view.display(.init(location: model.location,
                           description: model.description,
                           isLoading: true,
                           isRetryAvailable: false,
                           image: nil))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(.init(location: model.location,
                           description: model.description,
                           isLoading: false,
                           isRetryAvailable: true,
                           image: nil))
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingImage_displaysLoadingImage() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        
        sut.didStartLoadingImage(for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.isRetryAvailable, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageDatawithError_displaysRetry() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.isRetryAvailable, true)
        XCTAssertNil(message?.image)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt64 = #line) -> (sut: FeedImagePresenter<ViewSpy>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel]()
        
        func display(_ viewModel: FeedImageViewModel) {
            messages.append(viewModel)
        }
    }
}
