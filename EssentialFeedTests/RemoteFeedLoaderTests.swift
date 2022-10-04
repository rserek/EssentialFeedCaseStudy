//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 04/10/2022.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_noDataLoadedFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
