//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by KM on 06.12.2024.
//

import Foundation
//inernal is default scope but we still decorate it here to be more consistent

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
    
}
