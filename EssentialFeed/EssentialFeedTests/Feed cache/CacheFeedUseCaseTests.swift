//
//  CacheFeedUseCase.swift
//  EssentialFeedTests
//
//  Created by KM on 16.01.2025.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore){
        
    }
}

class FeedStore {
    var deletedCacheFeedCallCount = 0
}

class CacheFeedUseCase: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deletedCacheFeedCallCount, 0)
    }
    
}
