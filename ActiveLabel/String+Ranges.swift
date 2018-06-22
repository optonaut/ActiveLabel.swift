//
//  String+Ranges.swift
//  ActiveLabel
//
//  Created by Vladislav Kachan on 22.06.2018.
//  Copyright © 2018 Optonaut. All rights reserved.
//

import Foundation

extension String {
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = self.range(
            of: substring,
            options: options,
            range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
                ranges.append(range)
        }
        return ranges
    }
}
