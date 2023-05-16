//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 16/05/2023.
//

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: Self {
        return .init(message: nil)
    }
    
    static func error(message: String) -> Self {
        return .init(message: message)
    }
}
