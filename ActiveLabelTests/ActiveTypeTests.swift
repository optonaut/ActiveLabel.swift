//
//  ActiveTypeTests.swift
//  ActiveTypeTests
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import XCTest
@testable import ActiveLabel

extension ActiveElement: Equatable {}

func ==(a: ActiveElement, b: ActiveElement) -> Bool {
    switch (a, b) {
    case (.Mention(let a), .Mention(let b)) where a == b: return true
    case (.Hashtag(let a), .Hashtag(let b)) where a == b: return true
    case (.URL(let a), .URL(let b)) where a == b: return true
    case (.None, .None): return true
    default: return false
    }
}

class ActiveTypeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInvalid() {
        XCTAssertEqual(activeElement(""), ActiveElement.None)
        XCTAssertEqual(activeElement(" "), ActiveElement.None)
        XCTAssertEqual(activeElement("x"), ActiveElement.None)
        XCTAssertEqual(activeElement("ಠ_ಠ"), ActiveElement.None)
        XCTAssertEqual(activeElement("😁"), ActiveElement.None)
    }
    
    func testMention() {
        XCTAssertEqual(activeElement("@userhandle"), ActiveElement.Mention("userhandle"))
        XCTAssertEqual(activeElement("@userhandle."), ActiveElement.Mention("userhandle"))
        XCTAssertEqual(activeElement("@_with_underscores_"), ActiveElement.Mention("_with_underscores_"))
        XCTAssertEqual(activeElement("@u"), ActiveElement.Mention("u"))
        XCTAssertEqual(activeElement("@."), ActiveElement.None)
        XCTAssertEqual(activeElement("@"), ActiveElement.None)
    }
    
    func testHashtag() {
        XCTAssertEqual(activeElement("#somehashtag"), ActiveElement.Hashtag("somehashtag"))
        XCTAssertEqual(activeElement("#somehashtag."), ActiveElement.Hashtag("somehashtag"))
        XCTAssertEqual(activeElement("#_with_underscores_"), ActiveElement.Hashtag("_with_underscores_"))
        XCTAssertEqual(activeElement("#h"), ActiveElement.Hashtag("h"))
        XCTAssertEqual(activeElement("#."), ActiveElement.None)
        XCTAssertEqual(activeElement("#"), ActiveElement.None)
    }
    
    func testURL() {
        XCTAssertEqual(activeElement("http://www.google.com"), ActiveElement.URL("http://www.google.com"))
        XCTAssertEqual(activeElement("https://www.google.com"), ActiveElement.URL("https://www.google.com"))
        XCTAssertEqual(activeElement("https://www.google.com."), ActiveElement.URL("https://www.google.com"))
        XCTAssertEqual(activeElement("www.google.com"), ActiveElement.URL("www.google.com"))
        XCTAssertEqual(activeElement("google.com"), ActiveElement.URL("google.com"))
    }
    
}
