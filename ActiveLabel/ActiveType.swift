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
    case URL(String)
    case Mail(String)
    case Custom(String)

    static func create(with activeType: ActiveType, text: String) -> ActiveElement {
        switch activeType {
        case .Mention: return Mention(text)
        case .Hashtag: return Hashtag(text)
        case .URL: return URL(text)
        case .Mail: return Mail(text)
        case .Custom: return Custom(text)
        }
    }
}

public enum ActiveType {
    case Mention
    case Hashtag
    case URL
    case Mail
    case Custom(pattern: String)

    var pattern: String {
        switch self {
        case .Mention: return RegexParser.mentionPattern
        case .Hashtag: return RegexParser.hashtagPattern
        case .URL: return RegexParser.urlPattern
        case .Mail: return RegexParser.mailPattern
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
        case .Mail: return -4
        case .Custom(let regex): return regex.hashValue
        }
    }
}

public func ==(lhs: ActiveType, rhs: ActiveType) -> Bool {
    switch (lhs, rhs) {
    case (.Mention, .Mention): return true
    case (.Hashtag, .Hashtag): return true
    case (.URL, .URL): return true
    case (.Mail, .Mail): return true
    case (.Custom(let pattern1), .Custom(let pattern2)): return pattern1 == pattern2
    default: return false
    }
}

typealias ActiveFilterPredicate = (String -> Bool)

struct ActiveBuilder {

    static func createElements(type: ActiveType, from text: String, range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        switch type {
        case .Mention, .Hashtag:
            return createElementsIgnoringFirstCharacter(from: text, for: type, range: range, filterPredicate: filterPredicate)
        case .URL, .Custom, .Mail:
            return createElements(from: text, for: type, range: range, filterPredicate: filterPredicate)
        }
    }

    private static func createElements(from text: String,
                                            for type: ActiveType,
                                                range: NSRange,
                                                filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > 2 {
            let word = nsstring.substringWithRange(match.range)
                .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }

    private static func createElementsIgnoringFirstCharacter(from text: String,
                                                                  for type: ActiveType,
                                                                      range: NSRange,
                                                                      filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > 2 {
            let range = NSRange(location: match.range.location + 1, length: match.range.length - 1)
            var word = nsstring.substringWithRange(range)
            if word.hasPrefix("@") {
                word.removeAtIndex(word.startIndex)
            }
            else if word.hasPrefix("#") {
                word.removeAtIndex(word.startIndex)
            }

            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
        
    }
    
}
