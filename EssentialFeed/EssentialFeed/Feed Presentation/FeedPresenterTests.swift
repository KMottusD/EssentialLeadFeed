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
    
    func didStartLoadingFeed() {
        
    }
}

class FeedPresenterTests: XCTestCase {
   
    func test_init_doesNotSendMessagesToView() {
        
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemmoryLeaks(view, file: file, line: line)
        trackForMemmoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    //View as collaborator
    private class ViewSpy {
        
        enum Message: Equatable {
            case display(errorMessage: String?)
        }
        
        let messages = [Message]()
    }
}
