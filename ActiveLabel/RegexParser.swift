//
//  RegexParser.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 06/01/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

struct RegexParser {
    
    static let hashtagRegex = try? NSRegularExpression(pattern: "(?:^|\\s|$)#[\\p{L}0-9_]*", options: [.CaseInsensitive])
    static let mentionRegex = try? NSRegularExpression(pattern: "(?:^|\\s|$|[.])@[\\p{L}0-9_]*", options: [.CaseInsensitive]);
    static let urlDetector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue)
    static let phoneDetector = try? NSDataDetector(types: NSTextCheckingType.PhoneNumber.rawValue)
    
    static func getMentions(fromText text: String, range: NSRange, regex: NSRegularExpression? = mentionRegex) -> [NSTextCheckingResult] {
        var localRegex: NSRegularExpression
        if let regex = regex {
            localRegex = regex
        } else {
            guard let mentionRegex = mentionRegex else { return [] }
            localRegex = mentionRegex
        }
        return localRegex.matchesInString(text, options: [], range: range)
    }
    
    static func getHashtags(fromText text: String, range: NSRange, regex: NSRegularExpression? = hashtagRegex) -> [NSTextCheckingResult] {
        var localRegex: NSRegularExpression
        if let regex = regex {
            localRegex = regex
        } else {
            guard let hashtagRegex = hashtagRegex else { return [] }
            localRegex = hashtagRegex
        }
        return localRegex.matchesInString(text, options: [], range: range)
    }
    
    static func getURLs(fromText text: String, range: NSRange, regex: NSRegularExpression? = urlDetector) -> [NSTextCheckingResult] {
        var localRegex: NSRegularExpression
        if let regex = regex {
            localRegex = regex
        } else {
            guard let urlDetector = urlDetector else { return [] }
            localRegex = urlDetector
        }
        return localRegex.matchesInString(text, options: [], range: range)
    }
    
    static func getPhoneNumbers(fromText text: String, range: NSRange, regex: NSRegularExpression? = phoneDetector) -> [NSTextCheckingResult] {
        var localRegex: NSRegularExpression
        if let regex = regex {
            localRegex = regex
        } else {
            guard let phoneDetector = phoneDetector else { return [] }
            localRegex = phoneDetector
        }
        return localRegex.matchesInString(text, options: [], range: range)
    }
    
}