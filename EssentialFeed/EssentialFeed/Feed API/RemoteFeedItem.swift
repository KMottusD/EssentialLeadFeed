//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by KM on 21.01.2025.
//

import Foundation
struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
    
}
