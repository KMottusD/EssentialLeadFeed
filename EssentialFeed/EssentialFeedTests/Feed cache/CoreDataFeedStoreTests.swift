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
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .success(.empty))
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        sut.insert(feed.local, timestamp: timestamp, completion: { _ in })
        
        expect(sut, toRetrieve: .success(.found(feed: feed.local, timestamp: timestamp)))
        
    }
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
        let sut = makeSUT()
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        sut.insert(feed.local, timestamp: timestamp, completion: { _ in })
        expect(sut, toRetrieveTwice: .success(.found(feed: feed.local, timestamp: timestamp)))
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
        let sut = makeSUT()
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        _ = insert((uniqueImageFeed().local, Date()), to: sut)
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to override cache successfully")
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        _ = insert((uniqueImageFeed().local, Date()), to: sut)
        
        let latestFeed = [LocalFeedImage]()
        let latestTimestamp = Date()
        _ = insert((latestFeed, latestTimestamp), to: sut)
        
        expect(sut, toRetrieve: .success(.found(feed: latestFeed, timestamp: latestTimestamp)))
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        deleteCache(from: sut)
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        _ = insert((uniqueImageFeed().local, Date()), to: sut)

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        _ = insert((uniqueImageFeed().local, Date()), to: sut)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.empty))
        
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCacheFeed { _ in
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            op3.fulfill()
        }

        let op4 = expectation(description: "Operation 4")
        sut.retrieve { _ in
            op4.fulfill()
        }
        wait(for: [op1, op2, op3, op4], timeout: 5.0, enforceOrder: true)
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemmoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.success(.empty), .success(.empty)),
                 (.failure, .failure):
                break
                
            case let (.success(.found(expectedFeed, expectedTimestamp)), .success(.found(retrievedFeed, retrievedTimestamp))):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: CoreDataFeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCacheFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
        
    }
}
