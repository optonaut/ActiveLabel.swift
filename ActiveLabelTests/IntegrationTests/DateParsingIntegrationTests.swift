//
//  DateParsingTests.swift
//  ActiveLabelTests
//
//  Created by Alex Bush | Upkeep on 6/29/21.
//  Copyright © 2021 Optonaut. All rights reserved.
//

import XCTest
@testable import ActiveLabel

final class DateParsingIntegrationTests: BaseIntegrationTestCase {
    // MARK: - BEGIN Parsing
    func testItShouldNotRecognizeAnyDatesInTextWithoutDates() {
        // given
        label.enabledTypes = [.date]
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        // when
        let numberOfRecognizedPatterns = activeElements.count
        // then
        XCTAssertEqual(numberOfRecognizedPatterns, 0, "there shouldn't be any matches in a text that doesn't have any dates in it")
    }
    
    func testItShouldFindTheRightMatchesInTextWithDates() {
        // given
        let dateMock1 = "2018-08-31"
        let dateMock2 = "June 5th, 2021"
        label.enabledTypes = [.date]
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation \(dateMock1) ullamco laboris nisi ut aliquip ex ea commodo consequat. \(dateMock2) Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        // when
        let numberOfRecognizedPatterns = activeElements.count
        // then
        XCTAssertEqual(numberOfRecognizedPatterns, 2, "there should be matches in a text that contains dates")
        let firstDateMatch = activeElements[0]
        if case .date(let dateText) = firstDateMatch {
            XCTAssertEqual(dateText, dateMock1)
        } else {
            XCTFail("first date should match")
        }

        let secondDateMatch = activeElements[1]
        if case .date(let date) = secondDateMatch {
            XCTAssertEqual(date, dateMock2)
        } else {
            XCTFail("second date should match")
        }
    }
    
    func testItShouldFindOnlyDateMatchesInATextWithEmailPhoneAndOtherElementsGivenDateAsTheOnlyEnabledType() {
        // given
        let dateMock1 = "2018-08-31"
        let dateMock2 = "June 5th, 2021"
        label.enabledTypes = [.date]
        label.text = "Lorem ipsum dolor sit amet, @mention_of_something consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna \(dateMock1) aliqua. Ut #andahashtag enim ad minim veniam, quis email@somemail.com nostrud exercitation 202-555-0123 ullamco laboris nisi ut aliquip ex ea commodo consequat. +1-202-555-0116 Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui \(dateMock2) officia deserunt mollit anim id est laborum."
        // when
        let numberOfRecognizedPatterns = activeElements.count
        // then
        XCTAssertEqual(numberOfRecognizedPatterns, 2, "there should be matches in a text that contains dates")
    }
    
    func testItShouldFindDateAndOtherMatchesInATextWithMultipleDifferentElements() {
        // given
        let dateMock1 = "2018-08-31"
        label.enabledTypes = [.mention, .hashtag, .email, .phone, .address, .date]
        label.text = "Lorem ipsum dolor sit amet, @mention_of_something consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut #andahashtag enim ad minim veniam, quis email@somemail.com nostrud exercitation 202-555-0123 ullamco laboris nisi ut aliquip ex ea commodo consequat. +1-202-555-0116 Duis aute irure dolor in reprehenderit \(dateMock1) in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        // when
        let numberOfRecognizedPatterns = activeElements.count
        // then
        XCTAssertEqual(numberOfRecognizedPatterns, 6, "there should be several different matches in a text that contains dates and other elements")
        XCTAssertEqual(activeElements(perType: .mention("")).count, 1)
        XCTAssertEqual(activeElements(perType: .hashtag("")).count, 1)
        XCTAssertEqual(activeElements(perType: .email("")).count, 1)
        XCTAssertEqual(activeElements(perType: .phone("")).count, 2)
        XCTAssertEqual(activeElements(perType: .date("")).count, 1)
    }
    // MARK: END Parsing -

    // MARK: - BEGIN Handler Removal
    func testItRemovesDateHandlerClosure() {
        // given
        label.handleDateTap(handler: {_ in })
        XCTAssertNotNil(label.handleDateTap)
        // when
        label.removeHandle(for: .date)
        // then
        XCTAssertNil(label.dateTapHandler)
    }
    // MARK: END Handler Removal -
}
