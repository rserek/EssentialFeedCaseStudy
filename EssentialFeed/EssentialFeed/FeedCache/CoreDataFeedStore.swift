//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Radosław Serek on 23/11/2022.
//

import Foundation

public class CoreDataFeedStore: FeedStore {
    public init() { }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    
}
