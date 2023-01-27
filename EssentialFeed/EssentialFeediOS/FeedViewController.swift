//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 07/12/2022.
//

import EssentialFeed
import UIKit

final public class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var tableModel: [FeedImage] = []
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = cellModel.location == nil
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        
        return cell
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            self?.refreshControl?.endRefreshing()

            if let feed = try? result.get() {
                self?.tableModel = feed
                self?.tableView.reloadData()
            }
        }
    }
}
