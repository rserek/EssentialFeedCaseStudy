//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 30/05/2023.
//

import EssentialFeed
import XCTest

struct FeedImageViewModel<Image> {
    let location: String?
    let description: String?
    let isLoading: Bool
    let isRetryAvailable: Bool
    let image: Image?
    
    var isLocationHidden: Bool {
        return location == nil
    }
}

protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private struct InvalidImageDataError: Error { }

    private let view: View
    private let imageTransformator: (Data) -> Image?

    init(view: View, imageTransformator: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformator = imageTransformator
    }
    
    func didStartLoadingImage(for model: FeedImage) {
        view.display(.init(location: model.location,
                           description: model.description,
                           isLoading: true,
                           isRetryAvailable: false,
                           image: nil))
    }
    
    func didFinishLoadingImageData(_ data: Data, for model: FeedImage) {
        let image = imageTransformator(data)
        view.display(.init(location: model.location,
                           description: model.description,
                           isLoading: false,
                           isRetryAvailable: image == nil,
                           image: image))
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
        let data = Data()
        
        sut.didFinishLoadingImageData(data, for: image)
        
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
        let data = Data()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformator: { _ in transformedData })
        
        sut.didFinishLoadingImageData(data, for: image)
        
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
