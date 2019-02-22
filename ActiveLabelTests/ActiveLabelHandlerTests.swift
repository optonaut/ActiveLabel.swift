//
//  ActiveLabelHandlerTests.swift
//  ActiveLabelTests
//
//  Created by Viktor Kalinchuk on 2/22/19.
//  Copyright © 2019 Optonaut. All rights reserved.
//

import XCTest
@testable import ActiveLabel

class ActiveLabelHandlerTests: XCTestCase {

    func testHandleMentionHandlerNotSet() {
        let handler = ActiveLabelHandler()
        let type = ActiveType.mention
        let element = ActiveElement.create(with: type, text: "@somebody")
        let result = handler.handle(selectedElement: (range: NSRange(location: 0, length: 1), element: element, type: type))

        XCTAssertFalse(result.handled)
        XCTAssertEqual(result.selectedText, "@somebody")
    }

    func testHandleMentionHandlerSet() {
        let handler = ActiveLabelHandler()
        let type = ActiveType.mention
        let element = ActiveElement.create(with: type, text: "@somebody")

        var handlerInvokationCount = 0
        handler.mentionTapHandler = { _ in
            handlerInvokationCount += 1
        }

        let result = handler.handle(selectedElement: (range: NSRange(location: 0, length: 1), element: element, type: type))

        XCTAssertTrue(result.handled)
        XCTAssertEqual(result.selectedText, "@somebody")
        XCTAssertEqual(handlerInvokationCount, 1)
    }

    func testHandleHashtagHandlerNotSet() {
        let handler = ActiveLabelHandler()
        let type = ActiveType.hashtag
        let element = ActiveElement.create(with: type, text: "#look")
        let result = handler.handle(selectedElement: (range: NSRange(location: 0, length: 1), element: element, type: type))

        XCTAssertFalse(result.handled)
        XCTAssertEqual(result.selectedText, "#look")
    }

    func testHandleHashtagHandlerSet() {
        let handler = ActiveLabelHandler()
        let type = ActiveType.hashtag
        let element = ActiveElement.create(with: type, text: "#look")

        var handlerInvokationCount = 0
        handler.hashtagTapHandler = { _ in
            handlerInvokationCount += 1
        }

        let result = handler.handle(selectedElement: (range: NSRange(location: 0, length: 1), element: element, type: type))

        XCTAssertTrue(result.handled)
        XCTAssertEqual(result.selectedText, "#look")
        XCTAssertEqual(handlerInvokationCount, 1)
    }

    func testHandleURLHandlerNotSet() {
        let handler = ActiveLabelHandler()
        let type = ActiveType.url
        let element = ActiveElement.create(with: type, text: "https://google.com")
        let result = handler.handle(selectedElement: (range: NSRange(location: 0, length: 1), element: element, type: type))

        XCTAssertFalse(result.handled)
        XCTAssertEqual(result.selectedText, "https://google.com")
    }

    func testHandleValidURLHandlerSet() {
        let handler = ActiveLabelHandler()
        let type = ActiveType.url
        let element = ActiveElement.create(with: type, text: "https://google.com")

        var handlerInvokationCount = 0
        handler.urlTapHandler = { _ in
            handlerInvokationCount += 1
        }

        let result = handler.handle(selectedElement: (range: NSRange(location: 0, length: 1), element: element, type: type))

        XCTAssertTrue(result.handled)
        XCTAssertEqual(result.selectedText, "https://google.com")
        XCTAssertEqual(handlerInvokationCount, 1)
    }

    // Tests a case, when URL creation with supplied string is impossible
    func testHandleInvalidURLHandlerSet() {
        let handler = ActiveLabelHandler()
        let type = ActiveType.url
        let element = ActiveElement.create(with: type, text: "")

        var handlerInvokationCount = 0
        handler.urlTapHandler = { _ in
            handlerInvokationCount += 1
        }

        let result = handler.handle(selectedElement: (range: NSRange(location: 0, length: 1), element: element, type: type))

        XCTAssertFalse(result.handled)
        XCTAssertEqual(result.selectedText, "")
        XCTAssertEqual(handlerInvokationCount, 0)
    }

    func testHandleURLEscapingHandlerSet() {
        let handler = ActiveLabelHandler()
        let type = ActiveType.url
        let element = ActiveElement.create(with: type, text: "https://ko.wikipedia.org/wiki/위키백과:대문")

        var handlerInvokationCount = 0
        handler.urlTapHandler = { _ in
            handlerInvokationCount += 1
        }

        let result = handler.handle(selectedElement: (range: NSRange(location: 0, length: 1), element: element, type: type))

        XCTAssertTrue(result.handled)
        XCTAssertEqual(result.selectedText, "https://ko.wikipedia.org/wiki/위키백과:대문")
        XCTAssertEqual(handlerInvokationCount, 1)
    }

}
