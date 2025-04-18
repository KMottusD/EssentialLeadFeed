//
//  FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by KM on 18.04.2025.
//

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public protocol FeedImageDataLoaderTask {
    func cancel()
}
