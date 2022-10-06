//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 06/10/2022.
//

import Foundation
import XCTest

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url, completionHandler: { _, _, _ in }).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_createsDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy()
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)

        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let task = URLSessionDataTaskSpy()
        let session = URLSessionSpy()
        session.stub(url: url, dataTask: task)
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)

        XCTAssertEqual(task.resumeCallCount, 1)
    }

    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var receivedURLs: [URL] = []
        private var stubs: [URL: URLSessionDataTaskSpy] = [:]
        
        func stub(url: URL, dataTask: URLSessionDataTaskSpy) {
            stubs[url] = dataTask
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() { }
    }
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount: Int = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}
