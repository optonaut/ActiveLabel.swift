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
    case (.Mail(let a), .Mail(let b)) where a == b: return true
    case (.URL(let a), .URL(let b)) where a == b: return true
    case (.Custom(let a), .Custom(let b)) where a == b: return true
    default: return false
    }
}

class ActiveTypeTests: XCTestCase {

    let label = ActiveLabel()
    let customEmptyType = ActiveType.Custom(pattern: "")

    var activeElements: [ActiveElement] {
        return label.activeElements.flatMap({$0.1.flatMap({$0.element})})
    }

    var currentElementString: String? {
        guard let currentElement = activeElements.first else { return nil }
        switch currentElement {
        case .Mention(let mention): return mention
        case .Hashtag(let hashtag): return hashtag
        case .URL(let url): return url
        case .Mail(let mail): return mail
        case .Custom(let element): return element
        }
    }

    var currentElementType: ActiveType? {
        guard let currentElement = activeElements.first else { return nil }
        switch currentElement {
        case .Mention: return .Mention
        case .Hashtag: return .Hashtag
        case .URL: return .URL
        case .Mail:  return .Mail
        case .Custom: return customEmptyType
        }
    }

    override func setUp() {
        super.setUp()
        label.enabledTypes = [.Mention, .Hashtag, .URL, .Mail]
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

    func testMail(){
        label.text = "test@email.com"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "test@email.com")
        XCTAssertEqual(currentElementType, ActiveType.Mail)

        label.text = "test@email.com."
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "test@email.com")
        XCTAssertEqual(currentElementType, ActiveType.Mail)

        label.text = "test.test@email.com"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "test.test@email.com")
        XCTAssertEqual(currentElementType, ActiveType.Mail)

        label.text = "test_test@email.com"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "test_test@email.com")
        XCTAssertEqual(currentElementType, ActiveType.Mail)

        label.text = "test.test@email.es"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "test.test@email.es")
        XCTAssertEqual(currentElementType, ActiveType.Mail)

        label.text = "test@email"
        XCTAssertEqual(activeElements.count, 0)
    }

    func testCustomType() {
        let newType = ActiveType.Custom(pattern: "\\sare\\b")
        label.enabledTypes.append(newType)

        label.text = "we are one"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "are")
        XCTAssertEqual(currentElementType, customEmptyType)

        label.text = "are. are"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "are")
        XCTAssertEqual(currentElementType, customEmptyType)

        label.text = "helloare are"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "are")
        XCTAssertEqual(currentElementType, customEmptyType)

        label.text = "google"
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

    func testOnlyMentionsEnabled() {
        label.enabledTypes = [.Mention]

        label.text = "@user #hashtag"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "user")
        XCTAssertEqual(currentElementType, ActiveType.Mention)

        label.text = "http://www.google.com"
        XCTAssertEqual(activeElements.count, 0)

        label.text = "#somehashtag"
        XCTAssertEqual(activeElements.count, 0)

        label.text = "@userNumberOne #hashtag http://www.google.com @anotheruser"
        XCTAssertEqual(activeElements.count, 2)
        XCTAssertEqual(currentElementString, "userNumberOne")
        XCTAssertEqual(currentElementType, ActiveType.Mention)
    }

    func testOnlyHashtagEnabled() {
        label.enabledTypes = [.Hashtag]

        label.text = "@user #hashtag"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "hashtag")
        XCTAssertEqual(currentElementType, ActiveType.Hashtag)

        label.text = "http://www.google.com"
        XCTAssertEqual(activeElements.count, 0)

        label.text = "@someuser"
        XCTAssertEqual(activeElements.count, 0)

        label.text = "#hashtagNumberOne #hashtag http://www.google.com @anotheruser"
        XCTAssertEqual(activeElements.count, 2)
        XCTAssertEqual(currentElementString, "hashtagNumberOne")
        XCTAssertEqual(currentElementType, ActiveType.Hashtag)
    }

    func testOnlyURLsEnabled() {
        label.enabledTypes = [.URL]

        label.text = "http://www.google.com #hello"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "http://www.google.com")
        XCTAssertEqual(currentElementType, ActiveType.URL)

        label.text = "@user"
        XCTAssertEqual(activeElements.count, 0)

        label.text = "#somehashtag"
        XCTAssertEqual(activeElements.count, 0)

        label.text = " http://www.apple.com @userNumberOne #hashtag http://www.google.com @anotheruser"
        XCTAssertEqual(activeElements.count, 2)
        XCTAssertEqual(currentElementString, "http://www.apple.com")
        XCTAssertEqual(currentElementType, ActiveType.URL)
    }
    func textOnlyEmailEnabled(){
        label.enabledTypes = [.Mail]

        label.text = "test@mail.com #hello"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "test@mail.com")
        XCTAssertEqual(currentElementType, ActiveType.Mail)

        label.text = "@user"
        XCTAssertEqual(activeElements.count, 0)

        label.text = "#somehashtag"
        XCTAssertEqual(activeElements.count, 0)

        label.text = " test1@mail.com @userNumberOne #hashtag test2@mail.com @anotheruser"
        XCTAssertEqual(activeElements.count, 2)
        XCTAssertEqual(currentElementString, "test1@mail.com")
        XCTAssertEqual(currentElementType, ActiveType.Mail)
    }
    func testOnlyCustomEnabled() {
        let newType = ActiveType.Custom(pattern: "\\sare\\b")
        label.enabledTypes = [newType]

        label.text = "http://www.google.com  are #hello"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "are")
        XCTAssertEqual(currentElementType, customEmptyType)
        
        label.text = "@user"
        XCTAssertEqual(activeElements.count, 0)
        
        label.text = "#somehashtag"
        XCTAssertEqual(activeElements.count, 0)
        
        label.text = " http://www.apple.com are @userNumberOne #hashtag http://www.google.com are @anotheruser"
        XCTAssertEqual(activeElements.count, 2)
        XCTAssertEqual(currentElementString, "are")
        XCTAssertEqual(currentElementType, customEmptyType)
    }
}
