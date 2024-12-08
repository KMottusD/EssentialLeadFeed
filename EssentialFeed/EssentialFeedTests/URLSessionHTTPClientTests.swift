//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by KM on 07.12.2024.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) {_,_,_ in}.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
        
    func test_getFromURL_resumeDataTaskWithURL() {
        let url = URL(string: "https://example.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    
    //MARK: - Helpers
    
    // From swift 5.5 further we need to use @unchecked Sendable to conform to swift new concurrency. While using @unchecked Sendable we also need to make sure that our decorated class will be thread-safe.
    final private class URLSessionSpy: URLSession, @unchecked Sendable {
        private var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask : URLSessionDataTask, @unchecked Sendable {
        override func resume(){ }
    }
    private class URLSessionDataTaskSpy: URLSessionDataTask, @unchecked Sendable {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}



