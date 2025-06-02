//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by KM on 01.06.2025.
//

import XCTest

final class FeedPresenter {
    init(view: Any) {
        
    }
}

class FeedPresenterTests: XCTestCase {
   
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    // MARK: - Helpers
    
    //View as collaborator
    private class ViewSpy {
        let messages = [Any]()
    }
}
