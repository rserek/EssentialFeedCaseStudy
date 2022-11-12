//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Radosław Serek on 06/10/2022.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private static var acceptableResponseCode = 200
        
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == acceptableResponseCode,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {  
            throw RemoteFeedLoader.Error.invalidData
        }

        return root.items
    }
}
