//
//  HTTPLURLResponse+StatusCode.swift
//  EssentialFeedTests
//
//  Created by KM on 12.06.2025.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
