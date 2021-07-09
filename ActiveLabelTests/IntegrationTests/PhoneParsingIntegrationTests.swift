//
//  PhoneParsingActiveTypeTests.swift
//  ActiveLabelTests
//
//  Created by Alex Bush | Upkeep on 6/29/21.
//  Copyright © 2021 Upkeep. All rights reserved.
//

import XCTest
@testable import ActiveLabel

final class PhoneParsingIntegrationTests: BaseIntegrationTestCase {
    // MARK: - BEGIN Parsing
    func testItShouldNotRecognizeAnyPhoneNumbersInTextWithoutPhoneNumbers() {
        // given
        label.enabledTypes = [.phone]
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        // when
        let numberOfRecognizedPatterns = activeElements.count
        // then
        XCTAssertEqual(numberOfRecognizedPatterns, 0, "there shouldn't be any matches in a text that doesn't have any phone numbers in it")
    }
    
    func testItShouldFindTheRightMatchesInTextWithPhoneNumbers() {
        // given
        let phoneNumberMock1 = "202-555-0123"
        let phoneNumberMock2 = "+1-202-555-0116"
        label.enabledTypes = [.phone]
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation \(phoneNumberMock1) ullamco laboris nisi ut aliquip ex ea commodo consequat. \(phoneNumberMock2) Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        // when
        let numberOfRecognizedPatterns = activeElements.count
        // then
        XCTAssertEqual(numberOfRecognizedPatterns, 2, "there should be matches in a text that contains phone numbers")
        let firstPhoneMatch = activeElements[0]
        if case .phone(let phoneNumberText) = firstPhoneMatch {
            XCTAssertEqual(phoneNumberText, phoneNumberMock1)
        } else {
            XCTFail("first phone number should match")
        }
        
        let secondPhoneMatch = activeElements[1]
        if case .phone(let phoneNumberText) = secondPhoneMatch {
            XCTAssertEqual(phoneNumberText, phoneNumberMock2)
        } else {
            XCTFail("second phone number should match")
        }
    }
    
    func testItShouldFindOnlyPhoneMatchesInATextWithEmailPhoneAndOtherElementsGivenPhoneAsTheOnlyEnabledType() {
        // given
        label.enabledTypes = [.phone]
        label.text = "Lorem ipsum dolor sit amet, @mention_of_something consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut #andahashtag enim ad minim veniam, quis email@somemail.com nostrud exercitation 202-555-0123 ullamco laboris nisi ut aliquip ex ea commodo consequat. +1-202-555-0116 Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        // when
        let numberOfRecognizedPatterns = activeElements.count
        // then
        XCTAssertEqual(numberOfRecognizedPatterns, 2, "there should be matches in a text that contains phone numbers")
    }
    
    func testItShouldFindPhoneAndOtherMatchesInATextWithMultipleDifferentElements() {
        // given
        label.enabledTypes = [.mention, .hashtag, .email, .phone]
        label.text = "Lorem ipsum dolor sit amet, @mention_of_something consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut #andahashtag enim ad minim veniam, quis email@somemail.com nostrud exercitation 202-555-0123 ullamco laboris nisi ut aliquip ex ea commodo consequat. +1-202-555-0116 Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        // when
        let numberOfRecognizedPatterns = activeElements.count
        // then
        XCTAssertEqual(numberOfRecognizedPatterns, 5, "there should be several different matches in a text that contains phone numbers and other elements")
        XCTAssertEqual(activeElements(perType: .mention("")).count, 1)
        XCTAssertEqual(activeElements(perType: .hashtag("")).count, 1)
        XCTAssertEqual(activeElements(perType: .email("")).count, 1)
        XCTAssertEqual(activeElements(perType: .phone("")).count, 2)
    }
    // MARK: END Parsing -

    // MARK: - BEGIN Handler Removal
    func testItRemovesPhoneHandlerClosure() {
        // given
        label.handlePhoneTap(handler: {_ in })
        XCTAssertNotNil(label.handlePhoneTap)
        // when
        label.removeHandle(for: .phone)
        // then
        XCTAssertNil(label.phoneTapHandler)
    }
    // MARK: END Handler Removal -
}
