//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Radosław Serek on 12/11/2022.
//

import Foundation

public class LocalFeedLoader: FeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Result<Void, Error>

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self = self else { return }
            
            switch deletionResult {
            case .success:
                self.cache(feed, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader {
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
                
            case .success:
                completion(.success([]))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
                
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }

            case .success:
                break
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { .init(id: $0.id,
                           description: $0.description,
                           location: $0.location,
                           url: $0.url)}
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}
