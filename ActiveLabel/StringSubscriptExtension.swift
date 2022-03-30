//
//  StringSubscriptExtension.swift
//  ActiveLabel
//
//  Created by Steve Kim on 2022/03/31.
//  Copyright © 2022 Optonaut. All rights reserved.
//

import Foundation

extension String {
    subscript(at range: NSRange?) -> Self? {
        guard let range = range else { return nil }
        let endIndexOf = range.location + range.length - 1
        let isSafeRange = range.location >= 0 && endIndexOf < count

        guard isSafeRange else { return nil }

        let startIndex = index(self.startIndex, offsetBy: range.location)
        let endIndex = index(self.startIndex, offsetBy: range.location + range.length)
        return Self(self[startIndex..<endIndex])
    }
}
