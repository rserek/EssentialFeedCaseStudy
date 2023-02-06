//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 06/02/2023.
//

import UIKit

final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T? = nil) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ viewModel: FeedImagePresentableModel<UIImage>) {
        object?.display(viewModel)
    }
}
