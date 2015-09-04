//
//  ActiveTypeTests.swift
//  ActiveTypeTests
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import XCTest
@testable import ActiveLabel

extension ActiveType: Equatable {}

func ==(a: ActiveType, b: ActiveType) -> Bool {
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
        XCTAssertEqual(activeType(""), ActiveType.None)
        XCTAssertEqual(activeType(" "), ActiveType.None)
        XCTAssertEqual(activeType("x"), ActiveType.None)
        XCTAssertEqual(activeType("ಠ_ಠ"), ActiveType.None)
        XCTAssertEqual(activeType("😁"), ActiveType.None)
    }
    
    func testMention() {
        XCTAssertEqual(activeType("@userhandle"), ActiveType.Mention("userhandle"))
        XCTAssertEqual(activeType("@_with_underscores_"), ActiveType.Mention("_with_underscores_"))
        XCTAssertEqual(activeType("@u"), ActiveType.Mention("u"))
        XCTAssertEqual(activeType("@"), ActiveType.None)
    }
    
    func testHashtag() {
        XCTAssertEqual(activeType("#somehashtag"), ActiveType.Hashtag("somehashtag"))
        XCTAssertEqual(activeType("#_with_underscores_"), ActiveType.Hashtag("_with_underscores_"))
        XCTAssertEqual(activeType("#h"), ActiveType.Hashtag("h"))
        XCTAssertEqual(activeType("#"), ActiveType.None)
    }
    
    func testURL() {
        XCTAssertEqual(activeType("http://www.google.com"), ActiveType.URL(NSURL(string: "http://www.google.com")!))
        XCTAssertEqual(activeType("https://www.google.com"), ActiveType.URL(NSURL(string: "https://www.google.com")!))
        XCTAssertEqual(activeType("www.google.com"), ActiveType.None)
        XCTAssertEqual(activeType("google.com"), ActiveType.None)
    }
    
}
