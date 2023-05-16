//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 07/12/2022.
//

import UIKit

protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

final public class ErrorView: UIView {
    public var message: String?
}

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView, FeedErrorView {
    var tableModel: [FeedImageCellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var delegate: FeedViewControllerDelegate?
    public let errorView = ErrorView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
                
        refresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }

    func display(_ viewModel: FeedErrorViewModel) {
        errorView.message = viewModel.message
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cancelCellControllerLoad(forRowAt: indexPath)
        }
    }
        
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
