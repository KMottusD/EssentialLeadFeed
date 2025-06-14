//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by KM on 14.06.2025.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
