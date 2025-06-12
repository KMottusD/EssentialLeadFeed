//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by KM on 30.01.2025.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}
