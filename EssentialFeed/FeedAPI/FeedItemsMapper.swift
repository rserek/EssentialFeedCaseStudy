//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Radosław Serek on 06/10/2022.
//

import Foundation

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    private static var acceptableResponseCode = 200
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == acceptableResponseCode else { throw RemoteFeedLoader.Error.invalidData }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map(\.feedItem)
    }
}
