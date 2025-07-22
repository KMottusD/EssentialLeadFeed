//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by KM on 22.07.2025.
//

import Foundation

public protocol FeedImageDataCache {
   typealias SaveResult = Result<Void,Swift.Error>
    
    func save(_ data: Data, for url: URL,completion: @escaping (SaveResult) -> Void)
}

extension FeedImageDataCache {
    public func saveIgnoreResult(_ data: Data,for url: URL) {
        self.save(data, for: url) { _ in }
    }
}
