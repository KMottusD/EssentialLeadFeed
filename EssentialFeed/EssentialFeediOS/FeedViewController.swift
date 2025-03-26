//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by KM on 26.03.2025.
//

import Foundation
import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var viewAppeard = false
    private var tableModel = [FeedImage]()
    
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
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        if !viewAppeard {
            refresh()
            viewAppeard = true
        }
    }
    
    @objc private func refresh() {
        refreshControl?.beginRefreshing()
    }
    
    @objc private func load() {
        refresh()
        loader?.load { [weak self] result in
            self?.tableModel = (try? result.get()) ?? []
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        return cell
    }
}
