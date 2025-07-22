//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialAppTests
//
//  Created by KM on 13.07.2025.
//

import XCTest
import EssentialFeed


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
    
    private class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
            
            let decoratee: FeedImageDataLoader
            let imageCache: FeedImageDataCache
            
            private class TaskWrapper: FeedImageDataLoaderTask {
                var wrapped: FeedImageDataLoaderTask?
                
                func cancel() {
                    wrapped?.cancel()
                }
            }
            
            public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
                self.decoratee = decoratee
                self.imageCache = cache
            }
            
            public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
                let task = TaskWrapper()
                task.wrapped = decoratee.loadImageData(from: url) { [weak self] result in
                    completion(result.map { imageData in
                        self?.imageCache.saveIgnoreResult(imageData, for: url)
                        return imageData
                    })
                }
                return task
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
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        messages.append((url,completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
}

public protocol FeedImageDataCache {
   typealias SaveResult = Result<Void,Swift.Error>
    
    func save(_ data: Data, for url: URL,completion: @escaping (SaveResult) -> Void)
}

extension FeedImageDataCache {
    func saveIgnoreResult(_ data: Data,for url: URL) {
        self.save(data, for: url) { _ in }
    }
}

