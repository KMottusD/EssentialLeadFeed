//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialAppTests
//
//  Created by KM on 13.07.2025.
//

import XCTest
import EssentialFeed
import EssentialApp


final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {

    func test_init_doesNotLoadImageData() {
      
        let (_, loader) = makeSUT()
        
        XCTAssertTrue(loader.loadedURLs.isEmpty, "Expected no loaded URL's")
    }
    
    func test_loadImageData_loadFromLoader() {
        let url = anyURL()
        let (sut,loader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.loadedURLs, [url], "Expected to load URLs from loader")
    }
    
    func test_cancelLoadImageData_cancelsLoaderTask() {
        let url = anyURL()
        let (sut,loader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url])
    }
    
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let data = anyData()
        let (sut,loader) = makeSUT()
        
        expect(sut, toCompleteWith: .success(data)) {
            loader.complete(with: data)
        }
    }
    
    func test_loadImageData_deliverFailureOnLoaderFailure() {
        let error = anyNSError()
        let (sut,loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(error)) {
            loader.complete(with: error)
        }
    }
    
    func test_loadImageData_cachesLoadedDataOnLoaderSuccess() {
        let url = anyURL()
        let cache = CacheSpy()
        let imageData = anyData()
        let (sut,loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: url) { _ in }
        loader.complete(with: imageData)
        
        XCTAssertEqual(cache.messages, [.save(data: imageData, for: url)],"Expected to cache loaded image data on success")
    }
    
    func test_loadImageData_doesNotCacheDataOnLoaderFailure() {
        let url = anyURL()
        let cache = CacheSpy()
        let error = anyNSError()
        let (sut,loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: url, completion: { _ in })
        loader.complete(with: error)
        
        XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache image data on load error")
    }
    
    //MARK Helpers:-
    
    private func makeSUT(cache: CacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImageDataLoader,loader: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(sut,file: file,line: line)
        trackForMemoryLeaks(loader,file: file,line: line)
        return (sut,loader)
    }
    
    func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
       let exp = expectation(description: "wait for load completion")
       _ = sut.loadImageData(from: anyURL()) { receivedResult in
           switch (receivedResult,expectedResult) {
           case let (.success(receivedData), .success(expectedData)):
               XCTAssertEqual(receivedData, expectedData)
           case (.failure,.failure):
               break
           default:
               XCTFail("Expected \(expectedResult) got \(receivedResult) instead")
           }
           exp.fulfill()
       }
       action()
       
       wait(for: [exp], timeout: 1.0)
   }
    
    private class CacheSpy: FeedImageDataCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save(data: Data, for: URL)
        }
        
        func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(data: data, for: url))
            completion(.success(()))
        }
    }
}

class FeedImageDataLoaderSpy: FeedImageDataLoader {
    
    private(set) var messages = [(url: URL, completion:  (FeedImageDataLoader.Result) -> Void)]()
    
    var loadedURLs: [URL] {
        return messages.map { $0.url }
    }
    var cancelledURLs = [URL]()
    
    private struct Task: FeedImageDataLoaderTask {
        let callback: () -> Void
        func cancel() { callback() }
    }
    
    func complete(with data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
    
    func complete(with error: NSError, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        messages.append((url,completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
}

