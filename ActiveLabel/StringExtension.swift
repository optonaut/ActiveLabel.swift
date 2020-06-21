//
//  StringTrimExtension.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 04/09/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

extension String {
    func trim(to maximumCharacters: Int) -> String {
        return "\(self[..<index(startIndex, offsetBy: maximumCharacters)])" + "..."
    }
}

extension NSString {
    open func ranges(of searchString: String) -> [NSRange] {
        var ranges = [NSRange]()
        var searchRange = NSRange(location: 0, length: self.length)
        var range = self.range(of: searchString)
        while range.location != NSNotFound {
            ranges.append(range)
            searchRange = NSRange(location: NSMaxRange(range), length: self.length - NSMaxRange(range))
            range = self.range(of: searchString, options: [], range: searchRange)
        }
        return ranges
    }
}
