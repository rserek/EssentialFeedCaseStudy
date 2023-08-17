//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Radosław Serek on 30/05/2023.
//

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: Self {
        return .init(message: nil)
    }
    
    static func error(message: String) -> Self {
        return .init(message: message)
    }
}
