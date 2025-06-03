//
//  UIREfreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by KM on 03.06.2025.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
