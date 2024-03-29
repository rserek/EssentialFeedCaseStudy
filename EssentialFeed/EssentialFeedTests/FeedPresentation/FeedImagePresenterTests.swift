//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 30/05/2023.
//

import EssentialFeed
import XCTest

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
    
    func test_didFinishLoadingImageDataWithError_displaysRetry() {
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
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageDataTransformation() {
        let (sut, view) = makeSUT(imageTransformator: fail)
        let image = uniqueImage()
        
        sut.didFinishLoadingImageData(Data(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.isRetryAvailable, true)
        XCTAssertNil(message?.image)
    }

    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
        let image = uniqueImage()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformator: { _ in transformedData })
        
        sut.didFinishLoadingImageData(Data(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.isRetryAvailable, false)
        XCTAssertEqual(message?.image, transformedData)
    }

    // MARK: - Helpers
    
    private func makeSUT(
imageTransformator: @escaping (Data) -> AnyImage? = { _ in nil },
        file: StaticString = #file,
        line: UInt64 = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformator: imageTransformator)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        
        return (sut, view)
    }
    
    private var fail: (Data) -> AnyImage? {
        return { _ in nil }
    }
    
    private struct AnyImage: Equatable { }
    
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ viewModel: FeedImageViewModel<AnyImage>) {
            messages.append(viewModel)
        }
    }
}
