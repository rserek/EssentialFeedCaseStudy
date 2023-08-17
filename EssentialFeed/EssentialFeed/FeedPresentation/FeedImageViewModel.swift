//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Radosław Serek on 30/05/2023.
//

public struct FeedImageViewModel<Image> {
    public let location: String?
    public let description: String?
    public let isLoading: Bool
    public let isRetryAvailable: Bool
    public let image: Image?
    
    public var isLocationHidden: Bool {
        return location == nil
    }
}
