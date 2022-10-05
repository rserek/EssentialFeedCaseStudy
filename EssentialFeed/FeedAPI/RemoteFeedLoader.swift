//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Radosław Serek on 04/10/2022.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.items))
                } else {
                    completion(.failure(.invalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

public extension RemoteFeedLoader {
    enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
}

private struct Root: Decodable {
    let items: [FeedItem]
}
