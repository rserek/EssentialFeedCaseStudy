//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 04/10/2022.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_noDataLoadedFromURL() {
        let (_, client) = makeSUT()

        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()

        XCTAssertEqual(client.requestedURLs, [url, url])
        XCTAssertEqual(client.requestedURL, url)
    }

    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)

        return (sut, client)
    }
    
    // MARK: - Test doubles
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        var requestedURLs: [URL] = []
        
        func get(from url: URL) {
            requestedURL = url
            requestedURLs.append(url)
        }
    }
}
