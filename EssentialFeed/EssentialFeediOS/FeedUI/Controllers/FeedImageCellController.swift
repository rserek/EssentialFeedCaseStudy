//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 04/02/2023.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
    private lazy var cell = FeedImageCell()
    private let delegate: FeedImageCellControllerDelegate
        
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view() -> UITableViewCell {
        delegate.didRequestImage()
        
        return cell
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
    }
    
    func display(_ viewModel: FeedImagePresentableModel<UIImage>) {
        cell.locationContainer.isHidden = viewModel.isLocationHidden
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageView.image = viewModel.image
        cell.onRetry = delegate.didRequestImage
        cell.feedImageRetryButton.isHidden = !viewModel.isRetryAvailable
        cell.feedImageContainer.isShimmering = viewModel.isLoading
    }
}
