//
//  ActiveType.swift
//  ActiveLabel
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import Foundation
import UIKit

enum ActiveElement {
    case mention(String)
    case hashtag(String)
    case url(original: String, trimmed: String)
    case custom(String)
    case emoji(range: NSRange, name: String, onImage: (_ word: String) -> UIImage?)

    static func create(with activeType: ActiveType, text: String) -> ActiveElement {
        switch activeType {
        case .mention: return mention(text)
        case .hashtag: return hashtag(text)
        case .url: return url(original: text, trimmed: text)
        case .custom: return custom(text)
        case .emoji(_, let onImage): return emoji(range: NSRange(), name: text, onImage: onImage)
        }
    }
}

public enum ActiveType {
    case mention
    case hashtag
    case url
    case custom(pattern: String)
    case emoji(pattern: String, onImage: (_ word: String) -> UIImage?)

    var pattern: String {
        switch self {
        case .mention: return RegexParser.mentionPattern
        case .hashtag: return RegexParser.hashtagPattern
        case .url: return RegexParser.urlPattern
        case .custom(let regex): return regex
        case .emoji(let regex, _): return regex
        }
    }
}

extension ActiveType: Hashable, Equatable {
    public var hashValue: Int {
        switch self {
        case .mention: return -1
        case .hashtag: return -2
        case .url: return -3
        case .custom(let regex): return regex.hashValue
        case .emoji(let regex, _): return regex.hashValue
        }
    }
}

public func ==(lhs: ActiveType, rhs: ActiveType) -> Bool {
    switch (lhs, rhs) {
    case (.mention, .mention): return true
    case (.hashtag, .hashtag): return true
    case (.url, .url): return true
    case (.custom(let pattern1), .custom(let pattern2)): return pattern1 == pattern2
    case (.emoji(let pattern1, _), .emoji(let pattern2, _)): return pattern1 == pattern2
    default: return false
    }
}
