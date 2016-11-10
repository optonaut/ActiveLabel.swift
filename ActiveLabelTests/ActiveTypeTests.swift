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

public func ==(a: ActiveElement, b: ActiveElement) -> Bool {
    switch (a, b) {
    case (.mention(let a), .mention(let b)) where a == b: return true
    case (.hashtag(let a), .hashtag(let b)) where a == b: return true
    case (.url(let a), .url(let b)) where a == b: return true
    case (.custom(let a), .custom(let b)) where a == b: return true
    default: return false
    }
}

class ActiveTypeTests: XCTestCase {
    
    let label = ActiveLabel()
    let customEmptyType = ActiveType.custom(pattern: "")
    
    var activeElements: [ActiveElement] {
        return label.activeElements.flatMap({$0.1.flatMap({$0.element})})
    }
    
    var currentElementString: String? {
        guard let currentElement = activeElements.first else { return nil }
        switch currentElement {
        case .mention(let mention): return mention
        case .hashtag(let hashtag): return hashtag
        case .url(let url, _): return url
        case .custom(let element): return element
        }
    }
    
    var currentElementType: ActiveType? {
        guard let currentElement = activeElements.first else { return nil }
        switch currentElement {
        case .mention: return .mention
        case .hashtag: return .hashtag
        case .url: return .url
        case .custom: return customEmptyType
        }
    }
    
    override func setUp() {
        super.setUp()
        label.enabledTypes = [.mention, .hashtag, .url]
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
        XCTAssertEqual(currentElementType, ActiveType.mention)
        
        label.text = "@userhandle."
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "userhandle")
        XCTAssertEqual(currentElementType, ActiveType.mention)

        label.text = "@_with_underscores_"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "_with_underscores_")
        XCTAssertEqual(currentElementType, ActiveType.mention)
        
        label.text = " . @userhandle"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "userhandle")
        XCTAssertEqual(currentElementType, ActiveType.mention)
        
        label.text = "@user#hashtag"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "user")
        XCTAssertEqual(currentElementType, ActiveType.mention)
        
        label.text = "@user@mention"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "user")
        XCTAssertEqual(currentElementType, ActiveType.mention)
        
        label.text = ".@userhandle"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "userhandle")
        XCTAssertEqual(currentElementType, ActiveType.mention)
        
        label.text = " .@userhandle"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "userhandle")
        XCTAssertEqual(currentElementType, ActiveType.mention)

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
        XCTAssertEqual(currentElementType, ActiveType.hashtag)

        label.text = "#somehashtag."
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "somehashtag")
        XCTAssertEqual(currentElementType, ActiveType.hashtag)

        label.text = "#_with_underscores_"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "_with_underscores_")
        XCTAssertEqual(currentElementType, ActiveType.hashtag)
        
        label.text = " . #somehashtag"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "somehashtag")
        XCTAssertEqual(currentElementType, ActiveType.hashtag)
        
        label.text = "#some#hashtag"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "some")
        XCTAssertEqual(currentElementType, ActiveType.hashtag)
        
        label.text = "#some@mention"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "some")
        XCTAssertEqual(currentElementType, ActiveType.hashtag)
        
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
        XCTAssertEqual(currentElementType, ActiveType.url)

        label.text = "https://www.google.com"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "https://www.google.com")
        XCTAssertEqual(currentElementType, ActiveType.url)

        label.text = "http://www.google.com."
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "http://www.google.com")
        XCTAssertEqual(currentElementType, ActiveType.url)

        label.text = "www.google.com"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "www.google.com")
        XCTAssertEqual(currentElementType, ActiveType.url)
        
        label.text = "pic.twitter.com/YUGdEbUx"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "pic.twitter.com/YUGdEbUx")
        XCTAssertEqual(currentElementType, ActiveType.url)
        
        label.text = "http://url.with.other.language/한글"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "http://url.with.other.language/한글")
        XCTAssertEqual(currentElementType, ActiveType.url)

        label.text = "google.com"
        XCTAssertEqual(activeElements.count, 0)
    }

    func testCustomType() {
        let newType = ActiveType.custom(pattern: "\\sare\\b")
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
    
    func testConfigureLinkAttributes() {
        // Customize label
        let newType = ActiveType.custom(pattern: "\\sare\\b")
        label.customize { label in
            label.enabledTypes = [newType]
            
            // Configure "are" to be system font / bold / 14
            label.configureLinkAttribute = { type, attributes, isSelected in
                var atts = attributes
                if case newType = type {
                    atts[NSFontAttributeName] = UIFont.boldSystemFont(ofSize: 14)
                }
                
                return atts
            }
            label.text = "we are one"
        }
        
        // Find attributed text
        let range = (label.text! as NSString).range(of: "are")
        let areText = label.textStorage.attributedSubstring(from: range)
        
        // Enumber after attributes and find our font
        var foundCustomAttributedStyling = false
        areText.enumerateAttributes(in: NSRange(location: 0, length: areText.length), options: [.longestEffectiveRangeNotRequired], using: { (attributes, range, stop) in
            foundCustomAttributedStyling = attributes[NSFontAttributeName] as? UIFont == UIFont.boldSystemFont(ofSize: 14)
        })

        XCTAssertTrue(foundCustomAttributedStyling)
    }

    func testRemoveHandleMention() {
        label.handleMentionTap({_ in })
        XCTAssertNotNil(label.handleMentionTap)
        
        label.removeHandle(for: .mention)
        XCTAssertNil(label.mentionTapHandler)
    }
    
    func testRemoveHandleHashtag() {
        label.handleHashtagTap({_ in })
        XCTAssertNotNil(label.handleHashtagTap)
        
        label.removeHandle(for: .hashtag)
        XCTAssertNil(label.hashtagTapHandler)
    }
    
    func testRemoveHandleURL() {
        label.handleURLTap({_ in })
        XCTAssertNotNil(label.handleURLTap)
        
        label.removeHandle(for: .url)
        XCTAssertNil(label.urlTapHandler)
    }
    
    func testRemoveHandleCustom() {
        let newType1 = ActiveType.custom(pattern: "\\sare1\\b")
        let newType2 = ActiveType.custom(pattern: "\\sare2\\b")
        
        label.handleCustomTap(for: newType1, handler: {_ in })
        label.handleCustomTap(for: newType2, handler: {_ in })
        XCTAssertEqual(label.customTapHandlers.count, 2)
        
        label.removeHandle(for: newType1)
        XCTAssertEqual(label.customTapHandlers.count, 1)
        
        label.removeHandle(for: newType2)
        XCTAssertEqual(label.customTapHandlers.count, 0)
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
        label.enabledTypes = [.mention]

        label.text = "@user #hashtag"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "user")
        XCTAssertEqual(currentElementType, ActiveType.mention)

        label.text = "http://www.google.com"
        XCTAssertEqual(activeElements.count, 0)

        label.text = "#somehashtag"
        XCTAssertEqual(activeElements.count, 0)

        label.text = "@userNumberOne #hashtag http://www.google.com @anotheruser"
        XCTAssertEqual(activeElements.count, 2)
        XCTAssertEqual(currentElementString, "userNumberOne")
        XCTAssertEqual(currentElementType, ActiveType.mention)
    }

    func testOnlyHashtagEnabled() {
        label.enabledTypes = [.hashtag]

        label.text = "@user #hashtag"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "hashtag")
        XCTAssertEqual(currentElementType, ActiveType.hashtag)

        label.text = "http://www.google.com"
        XCTAssertEqual(activeElements.count, 0)

        label.text = "@someuser"
        XCTAssertEqual(activeElements.count, 0)

        label.text = "#hashtagNumberOne #hashtag http://www.google.com @anotheruser"
        XCTAssertEqual(activeElements.count, 2)
        XCTAssertEqual(currentElementString, "hashtagNumberOne")
        XCTAssertEqual(currentElementType, ActiveType.hashtag)
    }

    func testOnlyURLsEnabled() {
        label.enabledTypes = [.url]

        label.text = "http://www.google.com #hello"
        XCTAssertEqual(activeElements.count, 1)
        XCTAssertEqual(currentElementString, "http://www.google.com")
        XCTAssertEqual(currentElementType, ActiveType.url)

        label.text = "@user"
        XCTAssertEqual(activeElements.count, 0)

        label.text = "#somehashtag"
        XCTAssertEqual(activeElements.count, 0)

        label.text = " http://www.apple.com @userNumberOne #hashtag http://www.google.com @anotheruser"
        XCTAssertEqual(activeElements.count, 2)
        XCTAssertEqual(currentElementString, "http://www.apple.com")
        XCTAssertEqual(currentElementType, ActiveType.url)
    }

    func testOnlyCustomEnabled() {
        let newType = ActiveType.custom(pattern: "\\sare\\b")
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

    func testStringTrimming() {
        let text = "Tweet with long url: https://twitter.com/twicket_app/status/649678392372121601 and short url: https://hello.co"
        label.urlMaximumLength = 30
        label.text = text

        XCTAssertNotEqual(text.characters.count, label.text!.characters.count)
    }
}
