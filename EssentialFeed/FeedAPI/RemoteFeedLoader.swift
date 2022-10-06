//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Radosław Serek on 04/10/2022.
//

import Foundation

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
                do {
                    let feedItems = try FeedItemsMapper.map(data, response)
                    completion(.success(feedItems))
                } catch {
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
