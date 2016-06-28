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
    
    let label = ActiveLabel()
    
    var activeElements: [ActiveElement] {
        return label.activeElements.flatMap({$0.1.flatMap({$0.element})})
    }
    
    var currentElementString: String? {
        guard let currentElement = activeElements.first else { return nil }
        switch currentElement {
        case .Mention(let mention):
            return mention
        case .Hashtag(let hashtag):
            return hashtag
        case .URL(let url):
            return url
        case .Custom(_, let optionaltag):
            return optionaltag
        case .None:
            return ""
        }
    }
    
    var currentElementType: ActiveType? {
        guard let currentElement = activeElements.first else { return nil }
        switch currentElement {
        case .Mention:
            return .Mention
        case .Hashtag:
            return .Hashtag
        case .URL:
            return .URL
        case .Custom:
            return .Custom
        case .None:
            return .None
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInvalid() {
        label.text = ""
        XCTAssertEqual(activeElements.count, 0)
        label.text = " "
        XCTAssertEqual(activeElements.count, 0)
        label.text = "x"
        XCTAssertEqual(activeElements.count, 0)
        label.text = "ಠ_ಠ"
        XCTAssertEqual(activeElements.count, 0)
        label.text = "😁"
        XCTAssertEqual(activeElements.count, 0)
    }
    
    func testMention() {
        label.text = "@userhandle"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "userhandle")
        XCTAssertEqual(currentElementType, ActiveType.Mention)
        
        label.text = "@userhandle."
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "userhandle")
        XCTAssertEqual(currentElementType, ActiveType.Mention)

        label.text = "@_with_underscores_"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "_with_underscores_")
        XCTAssertEqual(currentElementType, ActiveType.Mention)
        
        label.text = " . @userhandle"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "userhandle")
        XCTAssertEqual(currentElementType, ActiveType.Mention)
        
        label.text = "@user#hashtag"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "user")
        XCTAssertEqual(currentElementType, ActiveType.Mention)
        
        label.text = "@user@mention"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "user")
        XCTAssertEqual(currentElementType, ActiveType.Mention)
        
        label.text = ".@userhandle"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "userhandle")
        XCTAssertEqual(currentElementType, ActiveType.Mention)
        
        label.text = " .@userhandle"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "userhandle")
        XCTAssertEqual(currentElementType, ActiveType.Mention)

        label.text = "word@mention"
        XCTAssertEqual(activeElements.count, 0)
        label.text = "@u"
        XCTAssertEqual(activeElements.count, 0)
        label.text = "@."
        XCTAssertEqual(activeElements.count, 0)
        label.text = "@"
        XCTAssertEqual(activeElements.count, 0)
    }
    
    func testHashtag() {
        label.text = "#somehashtag"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "somehashtag")
        XCTAssertEqual(currentElementType, ActiveType.Hashtag)

        label.text = "#somehashtag."
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "somehashtag")
        XCTAssertEqual(currentElementType, ActiveType.Hashtag)

        label.text = "#_with_underscores_"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "_with_underscores_")
        XCTAssertEqual(currentElementType, ActiveType.Hashtag)
        
        label.text = " . #somehashtag"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "somehashtag")
        XCTAssertEqual(currentElementType, ActiveType.Hashtag)
        
        label.text = "#some#hashtag"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "some")
        XCTAssertEqual(currentElementType, ActiveType.Hashtag)
        
        label.text = "#some@mention"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "some")
        XCTAssertEqual(currentElementType, ActiveType.Hashtag)
        
        label.text = ".#somehashtag"
        XCTAssertEqual(activeElements.count, 0)
        label.text = " .#somehashtag"
        XCTAssertEqual(activeElements.count, 0)
        label.text = "word#hashtag"
        XCTAssertEqual(activeElements.count, 0)
        label.text = "#h"
        XCTAssertEqual(activeElements.count, 0)
        label.text = "#."
        XCTAssertEqual(activeElements.count, 0)
        label.text = "#"
        XCTAssertEqual(activeElements.count, 0)
    }
    
    func testURL() {
        label.text = "http://www.google.com"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "http://www.google.com")
        XCTAssertEqual(currentElementType, ActiveType.URL)

        label.text = "https://www.google.com"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "https://www.google.com")
        XCTAssertEqual(currentElementType, ActiveType.URL)

        label.text = "http://www.google.com."
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "http://www.google.com")
        XCTAssertEqual(currentElementType, ActiveType.URL)

        label.text = "www.google.com"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "www.google.com")
        XCTAssertEqual(currentElementType, ActiveType.URL)
        
        label.text = "pic.twitter.com/YUGdEbUx"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "pic.twitter.com/YUGdEbUx")
        XCTAssertEqual(currentElementType, ActiveType.URL)

        label.text = "google.com"
        XCTAssertEqual(activeElements.count, 0)
    }

    func testFiltering() {
        label.text = "@user #tag"
        XCTAssertEqual(activeElements.count, 2)

        label.filterMention { $0 != "user" }
        XCTAssertEqual(activeElements.count, 1)

        label.filterHashtag { $0 != "tag" }
        XCTAssertEqual(activeElements.count, 0)
    }
    
    // test for issue https://github.com/optonaut/ActiveLabel.swift/issues/64
    func testIssue64pic() {
        label.text = "picfoo"
        XCTAssertEqual(activeElements.count, 0)
    }
    
    // test for issue https://github.com/optonaut/ActiveLabel.swift/issues/64
    func testIssue64www() {
        label.text = "wwwbar"
        XCTAssertEqual(activeElements.count, 0)
    }
}
