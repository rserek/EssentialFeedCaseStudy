//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 16/05/2023.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
