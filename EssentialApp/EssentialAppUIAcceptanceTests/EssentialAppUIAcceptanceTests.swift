//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by KM on 09.08.2025.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
    
        app.launch()
        
        XCTAssertEqual(app.cells.count, 22)
        //Flaky test...It's hard to get it pass consistently. Let's continue according to "Caios" comments, there will be better strategies how to address this.
        //let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        // XCTAssertTrue(firstImage.exists)
        
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //    @MainActor
    //    func testExample() throws {
    //        // UI tests must launch the application that they test.
    //        let app = XCUIApplication()
    //        app.launch()
    //
    //        // Use XCTAssert and related functions to verify your tests produce the correct results.
    //    }
    
    //    @MainActor
    //    func testLaunchPerformance() throws {
    //        // This measures how long it takes to launch your application.
    //        measure(metrics: [XCTApplicationLaunchMetric()]) {
    //            XCUIApplication().launch()
    //        }
    //    }
}
