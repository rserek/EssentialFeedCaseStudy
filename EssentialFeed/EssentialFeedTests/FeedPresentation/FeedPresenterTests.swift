//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 30/05/2023.
//

import EssentialFeed
import XCTest

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: Self {
        return .init(message: nil)
    }
    
    static func error(message: String) -> Self {
        return .init(message: message)
    }
}

final class FeedPresenter {
    private let loadingView: FeedLoadingView
    private let feedView: FeedView
    private let errorView: FeedErrorView

    static var title: String {
        return NSLocalizedString("feed_view_title",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }

    private var feedLoadError: String {
        return NSLocalizedString(
            "feed_view_connection_error",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server"
        )
    }

    init(loadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoading(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoading(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}

final class FeedPresenterTests: XCTestCase {
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("feed_view_title"))
    }
    
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
                
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages,
                       [.display(errorMessage: .none),
                        .display(isLoading: true)])
    }
    
    func test_didFinishLoadingWithFeed_displaysFeedAndStopsLoading() {
        let (sut, view) = makeSUT()
        let feed = uniqueImageFeed().models
        
        sut.didFinishLoading(with: feed)
        
        XCTAssertEqual(view.messages,
                       [.display(feed: feed),
                        .display(isLoading: false)])

    }

    func test_didFinishLoadingFeedWithError_displaysErrorAndStopLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoading(with: anyNSError())
        
        XCTAssertEqual(view.messages,
                       [.display(errorMessage: localized("feed_view_connection_error")),
                        .display(isLoading: false)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt64 = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(loadingView: view, feedView: view, errorView: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)

        if value == key {
            XCTFail("Missing localized string for key: \(key) in table \(table)", file: file, line: line)
        }
        
        return value
    }

    private final class ViewSpy: FeedLoadingView, FeedView, FeedErrorView {
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }

        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
    }
}
