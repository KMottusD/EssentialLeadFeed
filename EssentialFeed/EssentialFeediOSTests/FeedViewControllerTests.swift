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
    
    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_userInitiatedFeedReload_loadsFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadCallCount, 3)
        
    }
    
    func test_viewDidLoad_showsLoadingIndicator(){
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded() // viewDidLoad
        sut.replaceRefreshControlWIthFakeForIOS17Support()
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.beginAppearanceTransition(true, animated: false) // viewWillAppear
        sut.endAppearanceTransition() // viewIsAppearing + viewDidAppear
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        sut.refreshControl?.endRefreshing()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion(){
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading()
 
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
    }

    func test_userInitiatedFeedReload_showsLoadingIndicator(){
        let (sut, _) = makeSUT()
        //need to double check if that is correct as there are two seoerate solutions combined
        sut.replaceRefreshControlWIthFakeForIOS17Support()
        sut.refreshControl?.simulatePullToRefresh()
        sut.beginAppearanceTransition(true, animated: false) // viewWillAppear
        sut.endAppearanceTransition() // viewIsAppearing + viewDidAppear
        
        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }
    
    func test_userInitiatedFeedReload_hidesLoadingIndicatorOnLoaderCompletion(){
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading()
 
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
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
        
        func completeFeedLoading() {
            completions[0](.success([]))
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
    private var _isRegreshing = false
    
    override var isRefreshing: Bool { _isRegreshing }
    
    override func beginRefreshing() {
        _isRegreshing = true
    }
    
    override func endRefreshing() {
        _isRegreshing = false
    }
}
