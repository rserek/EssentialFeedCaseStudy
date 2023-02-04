//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 04/02/2023.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
