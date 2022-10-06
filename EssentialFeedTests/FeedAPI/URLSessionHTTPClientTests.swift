//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 06/10/2022.
//

import Foundation
import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url, completionHandler: { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let task = HTTPSessionTaskSpy()
        let session = HTTPSessionSpy()
        session.stub(url: url, dataTask: task)
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) { _ in }

        XCTAssertEqual(task.resumeCallCount, 1)
    }

    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://a-url.com")!
        let session = HTTPSessionSpy()
        let error = NSError(domain: "Invalid request", code: 400)
        session.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        
        let expectation = XCTestExpectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
                
            default:
                XCTFail("Expected failure with error \(error), got result \(result) instead")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private class HTTPSessionSpy: HTTPSession {
        private var stubs: [URL: Stub] = [:]
        
        private struct Stub {
            let dataTask: HTTPSessionTask
            let error: Error?
        }
        
        func stub(url: URL, dataTask: HTTPSessionTask = FakeHTTPSessionTask(), error: Error? = nil) {
            stubs[url] = Stub(dataTask: dataTask, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else {
                fatalError("Couldn't find stub for url \(url)")
            }
            
            completionHandler(nil, nil, stub.error)
            return stub.dataTask
        }
    }
    
    private class FakeHTTPSessionTask: HTTPSessionTask {
        func resume() { }
    }
    
    private class HTTPSessionTaskSpy: HTTPSessionTask {
        var resumeCallCount: Int = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
}
