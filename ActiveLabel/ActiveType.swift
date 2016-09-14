//
//  ActiveType.swift
//  ActiveLabel
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import Foundation

enum ActiveElement {
    case Mention(String)
    case Hashtag(String)
    case URL(original: String, trimmed: String)
    case Custom(String)

    static func create(with activeType: ActiveType, text: String) -> ActiveElement {
        switch activeType {
        case .Mention: return Mention(text)
        case .Hashtag: return Hashtag(text)
        case .URL: return URL(original: text, trimmed: text)
        case .Custom: return Custom(text)
        }
    }
}

public enum ActiveType {
    case Mention
    case Hashtag
    case URL
    case Custom(pattern: String)

    var pattern: String {
        switch self {
        case .Mention: return RegexParser.mentionPattern
        case .Hashtag: return RegexParser.hashtagPattern
        case .URL: return RegexParser.urlPattern
        case .Custom(let regex): return regex
        }
    }
}

extension ActiveType: Hashable, Equatable {
    public var hashValue: Int {
        switch self {
        case .Mention: return -1
        case .Hashtag: return -2
        case .URL: return -3
        case .Custom(let regex): return regex.hashValue
        }
    }
}

public func ==(lhs: ActiveType, rhs: ActiveType) -> Bool {
    switch (lhs, rhs) {
    case (.Mention, .Mention): return true
    case (.Hashtag, .Hashtag): return true
    case (.URL, .URL): return true
    case (.Custom(let pattern1), .Custom(let pattern2)): return pattern1 == pattern2
    default: return false
    }
}
