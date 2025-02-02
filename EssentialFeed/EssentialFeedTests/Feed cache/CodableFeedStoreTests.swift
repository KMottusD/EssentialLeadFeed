//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//  Created by KM on 02.02.2025.

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve (completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, but recieved result:  \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver some empty result, got: č \(firstResult) and \(secondResult)")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 0.1)
        
    }

}
