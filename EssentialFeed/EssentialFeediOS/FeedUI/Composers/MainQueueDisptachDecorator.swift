//
//  MainQueueDisptachDecorator.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 06/02/2023.
//

import EssentialFeed
import Foundation

final class MainQueueDisptachDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDisptachDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDisptachDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
