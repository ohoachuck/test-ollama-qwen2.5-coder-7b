//
//  test_ollama_qwen2_5_coder_7bUITestsLaunchTests.swift
//  test-ollama-qwen2.5-coder-7bUITests
//
//  Created by Olivier HO-A-CHUCK on 17/02/2026.
//

import XCTest

final class test_ollama_qwen2_5_coder_7bUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
