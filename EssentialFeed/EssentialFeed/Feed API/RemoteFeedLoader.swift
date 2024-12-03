 //
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by KM on 30.11.2024.
//
import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

// We can have it public, as we need to use it in testing. Another solution would be to use @testable in the test faile while importing the "EssentialFeed" module. But if possible we should use public here in this file.
// We mark it as final so that no one could subclass from our RemoteFeedLoader
public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result : Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient)
    {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if let _ = try? JSONSerialization.jsonObject(with: data){
                    completion(.success([]))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}


