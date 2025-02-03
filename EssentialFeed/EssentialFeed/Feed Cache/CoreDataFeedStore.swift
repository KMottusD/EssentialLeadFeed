//  CoreDataFeedStore.swift
//  EssentialFeed
//  Created by KM on 03.02.2025.

import Foundation

public final class CoreDataFeedStore: FeedStore {
    public init() {}

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }

}
