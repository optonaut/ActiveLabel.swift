//
//  RegexParser.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 06/01/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

struct RegexParser {
    
    static var urlPattern = "(^|[\\s.:;?\\-\\]<\\(])" +
    "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
    "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"
    
    static var hashtagRegex = try? NSRegularExpression(pattern: "(?:^|\\s|$)#[\\p{L}0-9_]*", options: [.CaseInsensitive])
    static var mentionRegex = try? NSRegularExpression(pattern: "(?:^|\\s|$|[.])@[\\p{L}0-9_]*", options: [.CaseInsensitive]);
    static var urlDetector = try? NSRegularExpression(pattern: urlPattern, options: [.CaseInsensitive])
    
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
    
    static func getOptionals(fromText text: String, pattern:String, range: NSRange) -> [NSTextCheckingResult] {
        if let match = try? NSRegularExpression(pattern: pattern, options: [.CaseInsensitive]).matchesInString(text, options: [], range: range) {
            return match
        }
        return []
    }
    
}