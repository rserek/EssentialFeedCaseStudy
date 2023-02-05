//
//  FeedImagePresentableModel.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 05/02/2023.
//

struct FeedImagePresentableModel<Image> {
    let location: String?
    let description: String?
    let isLoading: Bool
    let isRetryAvailable: Bool
    let image: Image?
    
    var isLocationHidden: Bool {
        return location == nil
    }
}
