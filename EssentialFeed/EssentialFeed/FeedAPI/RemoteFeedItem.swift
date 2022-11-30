//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Radosław Serek on 12/11/2022.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
