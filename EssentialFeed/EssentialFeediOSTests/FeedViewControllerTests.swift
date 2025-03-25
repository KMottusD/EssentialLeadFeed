//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by KM on 15.03.2025.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var viewAppeard = false
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
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
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)

        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut,loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount,0, "Expected no loading requests before view is laoded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request after user initiates reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed(){
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded() // viewDidLoad
        sut.replaceRefreshControlWIthFakeForIOS17Support()
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.beginAppearanceTransition(true, animated: false) // viewWillAppear
        sut.endAppearanceTransition() // viewIsAppearing + viewDidAppear
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        //Ios 17 on forward way
        sut.refreshControl?.endRefreshing()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
        
        sut.refreshControl?.beginRefreshing()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indication once loading is completed")
        
    }

    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemmoryLeaks(loader, file:file, line: line)
        trackForMemmoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    class LoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int) {
            completions[index](.success([]))
        }
    }

}

private extension FeedViewController {
    func replaceRefreshControlWIthFakeForIOS17Support() {
        let fake = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        refreshControl = fake
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform (Selector($0))
            }
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
}

//Safest way to rund tests.. FOR TESTING ONLY!!
private class FakeRefreshControl: UIRefreshControl {
    private var _isRefeshing = false
    
    override var isRefreshing: Bool { _isRefeshing }
    
    override func beginRefreshing() {
        _isRefeshing = true
    }
    
    override func endRefreshing() {
        _isRefeshing = false
    }
}
