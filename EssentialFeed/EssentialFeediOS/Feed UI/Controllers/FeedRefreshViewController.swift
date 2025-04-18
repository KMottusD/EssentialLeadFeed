//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by KM on 18.04.2025.
//

import UIKit
import EssentialFeed

public final class FeedRefreshViewController: NSObject {
    public lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let feedloader: FeedLoader
    
    init(feedloader: FeedLoader) {
        self.feedloader = feedloader
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc internal func refresh() {
        view.beginRefreshing()
        feedloader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}
