//
//  How_LuckyUITests.swift
//  How LuckyUITests
//
//  Created by Peyton White on 10/29/24.
//

import XCTest

final class How_LuckyUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testGameLayouts() throws {
        let app = XCUIApplication()
        for game in ["squares", "circles"] {
            app.launch()
            let link = app.buttons["game." + game]
            XCTAssertTrue(link.waitForExistence(timeout: 15))
            let reward = app.buttons["Thanks, bye"]
            if reward.exists { reward.tap() }
            link.tap()
            let board = app.otherElements["game.board"]
            XCTAssertTrue(board.waitForExistence(timeout: 10))
            XCTAssertGreaterThan(board.frame.height, app.frame.height * 0.5,
                                 "The game should occupy most of the phone screen.")
            XCTAssertTrue(app.buttons["Power-ups"].isHittable)
            let screenshot = XCTAttachment(screenshot: app.screenshot())
            screenshot.name = game + "-simple-layout"
            screenshot.lifetime = .keepAlways
            add(screenshot)
            app.terminate()
        }
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
