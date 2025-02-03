//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by KM on 03.02.2025.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result)")
            }
            exp.fulfill()
            
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // - MARK: Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let sut = CoreDataFeedStore()
        trackForMemmoryLeaks(sut, file: file, line: line)
        return sut
    }

}
