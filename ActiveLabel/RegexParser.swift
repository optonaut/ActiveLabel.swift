//
//  RegexParser.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 06/01/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

struct RegexParser {
    
    static let urlPattern = "(^|[\\s.:;?\\-\\]<\\(])" +
        "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
    "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"
    
    static let hashtagRegex = try? NSRegularExpression(pattern: "(?:^|\\s|$)#[\\p{L}0-9_]*", options: [.CaseInsensitive])
    static let mentionRegex = try? NSRegularExpression(pattern: "(?:^|\\s|$|[.])@[\\p{L}0-9_]*", options: [.CaseInsensitive]);
    static let urlDetector = try? NSRegularExpression(pattern: urlPattern, options: [.CaseInsensitive])
    static let dollarSignRegex = try? NSRegularExpression(pattern: "(?:^|\\s|$)\\$[a-z0-9_]*", options: [.CaseInsensitive])
    
    static func getMentions(fromText text: String, range: NSRange) -> [NSTextCheckingResult] {
        guard let mentionRegex = mentionRegex else { return [] }
        return mentionRegex.matchesInString(text, options: [], range: range)
    }
    
    static func getHashtags(fromText text: String, range: NSRange) -> [NSTextCheckingResult] {
        guard let hashtagRegex = hashtagRegex else { return [] }
        return hashtagRegex.matchesInString(text, options: [], range: range)
    }
    
    static func getURLs(fromText text: String, range: NSRange) -> [NSTextCheckingResult] {
        guard let urlDetector = urlDetector else { return [] }
        return urlDetector.matchesInString(text, options: [], range: range)
    }
    
    static func getDollarSign(fromText text: String, range: NSRange) -> [NSTextCheckingResult] {
        guard let dollarSignRegex = dollarSignRegex else { return [] }
        return dollarSignRegex.matchesInString(text, options: [], range: range)
    }
    
    static func getStringSign(fromText text: String, range: NSRange, word: String) -> [NSTextCheckingResult] {
        guard let regex = try? NSRegularExpression(pattern: word, options: [.IgnoreMetacharacters]) else { return [] }
        return regex.matchesInString(text, options: [], range: range)
    }
}