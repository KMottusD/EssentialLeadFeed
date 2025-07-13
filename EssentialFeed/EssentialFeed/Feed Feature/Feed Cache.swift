//
//  Feed Cache.swift
//  EssentialFeed
//
//  Created by KM on 13.07.2025.
//

import Foundation

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
