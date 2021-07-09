//
//  AddressParsingTests.swift
//  ActiveLabelTests
//
//  Created by Alex Bush | Upkeep on 6/29/21.
//  Copyright © 2021 Optonaut. All rights reserved.
//

import XCTest
@testable import ActiveLabel

final class AddressParsingIntegrationTests: BaseIntegrationTestCase {

    // MARK: - BEGIN Parsing
    func testItShouldNotRecognizeAnyAddressesInTextWithoutAddresses() {
        // given
        label.enabledTypes = [.address]
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        // when
        let numberOfRecognizedPatterns = activeElements.count
        // then
        XCTAssertEqual(numberOfRecognizedPatterns, 0, "there shouldn't be any matches in a text that doesn't have any addresses in it")
    }
    
    func testItShouldFindTheRightMatchesInTextWithAddresses() {
        // given
        let addressMock1 = "768 5th Ave"
        let addressMock2 = "124 Some St, Houston, TX 12345"
        label.enabledTypes = [.address]
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation \(addressMock1) ullamco laboris nisi ut aliquip ex ea commodo consequat. \(addressMock2) Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        // when
        let numberOfRecognizedPatterns = activeElements.count
        // then
        XCTAssertEqual(numberOfRecognizedPatterns, 2, "there should be matches in a text that contains addresses")
        let firstAddressMatch = activeElements[0]
        if case .address(let addressText) = firstAddressMatch {
            XCTAssertEqual(addressText, addressMock1)
        } else {
            XCTFail("first address should match")
        }

        let secondAddressMatch = activeElements[1]
        if case .address(let addressText) = secondAddressMatch {
            XCTAssertEqual(addressText, addressMock2)
        } else {
            XCTFail("second address should match")
        }
    }
    
    func testItShouldFindOnlyAddressMatchesInATextWithEmailPhoneAndOtherElementsGivenAddressAsTheOnlyEnabledType() {
        // given
        let addressMock1 = "768 5th Ave"
        let addressMock2 = "124 Some St, Houston, TX 12345"
        label.enabledTypes = [.address]
        label.text = "Lorem ipsum dolor sit amet, @mention_of_something consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna \(addressMock1) aliqua. Ut #andahashtag enim ad minim veniam, quis email@somemail.com nostrud exercitation 202-555-0123 ullamco laboris nisi ut aliquip ex ea commodo consequat. +1-202-555-0116 Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui \(addressMock2) officia deserunt mollit anim id est laborum."
        // when
        let numberOfRecognizedPatterns = activeElements.count
        // then
        XCTAssertEqual(numberOfRecognizedPatterns, 2, "there should be matches in a text that contains addresses")
    }
    
    func testItShouldFindAddressAndOtherMatchesInATextWithMultipleDifferentElements() {
        // given
        let addressMock1 = "768 5th Ave"
        label.enabledTypes = [.mention, .hashtag, .email, .phone, .address]
        label.text = "Lorem ipsum dolor sit amet, @mention_of_something consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut #andahashtag enim ad minim veniam, quis email@somemail.com nostrud exercitation 202-555-0123 ullamco laboris nisi ut aliquip ex ea commodo consequat. +1-202-555-0116 Duis aute irure dolor in reprehenderit \(addressMock1) in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        // when
        let numberOfRecognizedPatterns = activeElements.count
        // then
        XCTAssertEqual(numberOfRecognizedPatterns, 6, "there should be several different matches in a text that contains address and other elements")
        XCTAssertEqual(activeElements(perType: .mention("")).count, 1)
        XCTAssertEqual(activeElements(perType: .hashtag("")).count, 1)
        XCTAssertEqual(activeElements(perType: .email("")).count, 1)
        XCTAssertEqual(activeElements(perType: .phone("")).count, 2)
        XCTAssertEqual(activeElements(perType: .address("")).count, 1)
    }
    // MARK: END Parsing -

    // MARK: - BEGIN Handler Removal
    func testItRemovesAddressHandlerClosure() {
        // given
        label.handleAddressTap(handler: {_ in })
        XCTAssertNotNil(label.handleAddressTap)
        // when
        label.removeHandle(for: .address)
        // then
        XCTAssertNil(label.addressTapHandler)
    }
    // MARK: END Handler Removal -

}
