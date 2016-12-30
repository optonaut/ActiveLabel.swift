//
//  AttributedTextTests.swift
//  ActiveLabel
//
//  Created by Andrea Perizzato on 16/10/2016.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation
import XCTest
@testable import ActiveLabel

class AttributedTextTests: XCTestCase {
    
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
    }
    
    func testWithoutAttributedString() {
        
        label.hashtagColor = .red
        label.URLColor = .blue
        label.mentionColor = .orange
        label.textColor = .yellow
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline).withSize(30)
        let text = "simple text with #hashtags @user http://hello.com"
        let nstext = text as NSString
        label.text = text
                
        // Verify that `simple text with ` has the default font and text color
        var textRange = nstext.range(of: "simple text with ")
        var actualRange = NSRange(location: 0, length: 0)
        var textAttr = label.textStorage.attributes(at: textRange.location, effectiveRange: &actualRange)
        XCTAssertEqual(actualRange.location, textRange.location)
        XCTAssertEqual(actualRange.length, textRange.length)
        XCTAssertEqual(textAttr[NSFontAttributeName] as! UIFont, label.font!)
        XCTAssertEqual(textAttr[NSForegroundColorAttributeName] as? UIColor, label.textColor)
        
        // Verify that `#hashtags` has the default font and `hashtagColor` as text color
        textRange = nstext.range(of: "#hashtags")
        textAttr = label.textStorage.attributes(at: textRange.location, effectiveRange: &actualRange)
        XCTAssertEqual(actualRange.location, textRange.location)
        XCTAssertEqual(actualRange.length, textRange.length)
        XCTAssertEqual(textAttr[NSFontAttributeName] as! UIFont, label.font!)
        XCTAssertEqual(textAttr[NSForegroundColorAttributeName] as? UIColor, label.hashtagColor)
        
        // Verify that `user` has the default font and `mentionColor` as text color
        textRange = nstext.range(of: "@user")
        textAttr = label.textStorage.attributes(at: textRange.location, effectiveRange: &actualRange)
        XCTAssertEqual(actualRange.location, textRange.location)
        XCTAssertEqual(actualRange.length, textRange.length)
        XCTAssertEqual(textAttr[NSFontAttributeName] as! UIFont, label.font!)
        XCTAssertEqual(textAttr[NSForegroundColorAttributeName] as? UIColor, label.mentionColor)
        
        // Verify that `#hashtags` has the default font and `hashtagColor` as text color
        textRange = nstext.range(of: "http://hello.com")
        textAttr = label.textStorage.attributes(at: textRange.location, effectiveRange: &actualRange)
        XCTAssertEqual(actualRange.location, textRange.location)
        XCTAssertEqual(actualRange.length, textRange.length)
        XCTAssertEqual(textAttr[NSFontAttributeName] as! UIFont, label.font!)
        XCTAssertEqual(textAttr[NSForegroundColorAttributeName] as? UIColor, label.URLColor)
    }
    
    func testWithAttributedString() {
        
        // Setup the label
        label.hashtagColor = .red
        label.URLColor = .blue
        label.mentionColor = .orange
        label.textColor = .yellow
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline).withSize(200)
        
        // Attribued text
        let font1 = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        let color1 = UIColor.brown
        let underline1 = NSUnderlineStyle.styleDouble.rawValue
        let t1 = NSAttributedString(string: "simple text ", attributes: [
            NSFontAttributeName : font1,
            NSForegroundColorAttributeName : color1,
            NSUnderlineStyleAttributeName : underline1
        ])
        let font2 = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        let color2 = UIColor.black
        let underline2 = NSUnderlineStyle.patternDashDot.rawValue
        let t2 = NSAttributedString(string: "with #hashtags, @user http://hello.com", attributes: [
            NSFontAttributeName : font2,
            NSForegroundColorAttributeName : color2,
            NSUnderlineStyleAttributeName : underline2
        ])
        let attributedText = NSMutableAttributedString()
        attributedText.append(t1)
        attributedText.append(t2)
        label.attributedText = attributedText
        let nstext = attributedText.string as NSString
        
        // Verify that `simple text ` has the original font, color and underline
        var textRange = nstext.range(of: "simple text ")
        var actualRange = NSRange(location: 0, length: 0)
        var textAttr = label.textStorage.attributes(at: textRange.location, effectiveRange: &actualRange)
        XCTAssertEqual(actualRange.location, textRange.location)
        XCTAssertEqual(actualRange.length, textRange.length)
        XCTAssertEqual(textAttr[NSFontAttributeName] as! UIFont, font1)
        XCTAssertEqual(textAttr[NSForegroundColorAttributeName] as? UIColor, color1)
        XCTAssertEqual(textAttr[NSUnderlineStyleAttributeName] as? Int, underline1)
        
        // Verify that `#hashtags` has the original font and underline, but `hashtagColor` as color
        textRange = nstext.range(of: "#hashtags")
        textAttr = label.textStorage.attributes(at: textRange.location, effectiveRange: &actualRange)
        XCTAssertEqual(actualRange.location, textRange.location)
        XCTAssertEqual(actualRange.length, textRange.length)
        XCTAssertEqual(textAttr[NSFontAttributeName] as! UIFont, font2)
        XCTAssertEqual(textAttr[NSForegroundColorAttributeName] as? UIColor, label.hashtagColor)
        XCTAssertEqual(textAttr[NSUnderlineStyleAttributeName] as? Int, underline2)
        
        // Verify that `user` has the default font and `mentionColor` as text color
        textRange = nstext.range(of: "@user")
        textAttr = label.textStorage.attributes(at: textRange.location, effectiveRange: &actualRange)
        XCTAssertEqual(actualRange.location, textRange.location)
        XCTAssertEqual(actualRange.length, textRange.length)
        XCTAssertEqual(textAttr[NSFontAttributeName] as! UIFont, font2)
        XCTAssertEqual(textAttr[NSForegroundColorAttributeName] as? UIColor, label.mentionColor)
        XCTAssertEqual(textAttr[NSUnderlineStyleAttributeName] as? Int, underline2)
        
        // Verify that `#hashtags` has the default font and `hashtagColor` as text color
        textRange = nstext.range(of: "http://hello.com")
        textAttr = label.textStorage.attributes(at: textRange.location, effectiveRange: &actualRange)
        XCTAssertEqual(actualRange.location, textRange.location)
        XCTAssertEqual(actualRange.length, textRange.length)
        XCTAssertEqual(textAttr[NSFontAttributeName] as! UIFont, font2)
        XCTAssertEqual(textAttr[NSForegroundColorAttributeName] as? UIColor, label.URLColor)
        XCTAssertEqual(textAttr[NSUnderlineStyleAttributeName] as? Int, underline2)
    }

}
