//
//  RegexParserTest.swift
//  ActiveLabelTests
//
//  Created by Steve Kim on 2022/03/31.
//  Copyright © 2022 Optonaut. All rights reserved.
//

import XCTest
@testable import ActiveLabel

class RegexParserTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetElementsWithURLPattern() {
        let strings = [
            "http://www.google.com",
            "https://www.google.com",
            "www.google.com",
            "https://www.google.com에서 확인",
        ]
        let elements = strings.compactMap {
            RegexParser.getElements(from: $0, with: RegexParser.urlPattern, range: NSMakeRange(0, $0.count)).first
        }

        XCTAssertEqual(strings.count, elements.count)
    }

    func testRangeOfGetElementsWithURLPattern() {
        let string = "https://www.google.com에서 확인"
        let range = NSMakeRange(0, string.count)
        let rangeOfFirstElement = RegexParser.getElements(from: string, with: RegexParser.urlPattern, range: range).first!.range
        let startIndex = string.index(string.startIndex, offsetBy: rangeOfFirstElement.location)
        let endIndex = string.index(string.startIndex, offsetBy: rangeOfFirstElement.location + rangeOfFirstElement.length)
        let substring = string[startIndex..<endIndex]

        XCTAssertEqual("https://www.google.com", substring)
    }
}
