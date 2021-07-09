//
//  ActiveElement+UnitTestUtilities.swift
//  ActiveLabelTests
//
//  Created by Alex Bush | Upkeep on 7/6/21.
//  Copyright © 2021 Optonaut. All rights reserved.
//

import Foundation

@testable import ActiveLabel

extension ActiveElement: Equatable {}

public func ==(a: ActiveElement, b: ActiveElement) -> Bool {
    switch (a, b) {
    case (.mention(let a), .mention(let b)) where a == b: return true
    case (.hashtag(let a), .hashtag(let b)) where a == b: return true
    case (.url(let a), .url(let b)) where a == b: return true
    case (.custom(let a), .custom(let b)) where a == b: return true
    case (.phone(let a), .phone(let b)) where a == b: return true
    case (.address(let a), .address(let b)) where a == b: return true
    case (.date(let a), .date(let b)) where a == b: return true
    default: return false
    }
}
