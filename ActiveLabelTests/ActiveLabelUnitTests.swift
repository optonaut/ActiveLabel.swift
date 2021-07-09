//
//  ActiveLabelUnitTests.swift
//  ActiveLabelTests
//
//  Created by Alex Bush | Upkeep on 7/6/21.
//  Copyright © 2021 Optonaut. All rights reserved.
//

import XCTest
@testable import ActiveLabel

final class ActiveLabelUnitTests: XCTestCase {

    func testItShouldParseTextForElementsWhenTextChanges() {
        // given
        let mockActiveBuilder = MockActiveBuilder()
        let label = ActiveLabel(activeBuilder: mockActiveBuilder)
        label.enabledTypes = [.mention, .hashtag, .url]
        // when
        label.text = "some text"
        // then
        XCTAssertEqual(mockActiveBuilder.createURLElementsCallCount, 1, "it should call url elements creation only once")
        XCTAssertEqual(mockActiveBuilder.createElementsCallCount, 2, "it should call element creation for every other type of element besides url")
    }
    
    func testItShouldCallElementsCreationUponTextChanges() {
        // given
        let mockActiveBuilder = MockActiveBuilder()
        let label = ActiveLabel(activeBuilder: mockActiveBuilder)
        label.enabledTypes = [.mention, .hashtag, .url]
        // when
        label.text = "something"
        label.attributedText = NSAttributedString(string: "some other text")
        label.filterMention { (string) -> Bool in return false }
        label.filterHashtag { (string) -> Bool in return false }
        label.awakeFromNib()
        label.customize { (label) in }
        // then
        XCTAssertEqual(mockActiveBuilder.createURLElementsCallCount, 6, "it should call url elements creation only once per text change")
        XCTAssertEqual(mockActiveBuilder.createElementsCallCount, 12, "it should call element creation for every other type of element besides url per text change")
    }
    
    func testItShouldNotParseTextForElementsWhenTextDoesNotChange() {
        // given
        let mockActiveBuilder = MockActiveBuilder()
        let label = ActiveLabel(activeBuilder: mockActiveBuilder)
        label.enabledTypes = [.mention, .hashtag, .url]
        // when
        label.mentionColor = .black
        label.mentionSelectedColor = .black
        label.hashtagColor = .black
        label.hashtagSelectedColor = .black
        label.URLColor = .black
        label.URLSelectedColor = .black
        label.phoneColor = .black
        label.phoneSelectedColor = .black
        label.addressColor = .black
        label.addressSelectedColor = .black
        label.dateColor = .black
        label.dateSelectedColor = .black
        label.customColor = [.mention : .black]
        label.customSelectedColor = [.mention : .black]
        label.lineSpacing = 123.123
        label.minimumLineHeight = 123.123
        label.highlightFontName = nil
        label.highlightFontSize = nil
        label.font = UIFont()
        label.textColor = .black
        label.textAlignment = .center
        // then
        XCTAssertEqual(mockActiveBuilder.createURLElementsCallCount, 0)
        XCTAssertEqual(mockActiveBuilder.createElementsCallCount, 0)
    }

}
