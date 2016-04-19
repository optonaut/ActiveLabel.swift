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
    "((https?://|www.|pic.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
    "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"
    
    static let hashtagRegex = try? NSRegularExpression(pattern: "(?:^|\\s|$)#[\\p{L}0-9_]*", options: [.CaseInsensitive])
    static let mentionRegex = try? NSRegularExpression(pattern: "(?:^|\\s|$|[.])@[\\p{L}0-9_]*", options: [.CaseInsensitive]);
    static let urlDetector = try? NSRegularExpression(pattern: urlPattern, options: [.CaseInsensitive])
    static let phoneNumberRegex = try? NSRegularExpression(pattern: "(\\+?\\d{1,3})?\\s?-?\\(?\\d{2,4}\\)?\\s?-?\\d{3,4}-?\\d{4}", options: [.CaseInsensitive]);
    
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
    
    static func getPhoneNumbers(fromText text: String, range: NSRange) -> [NSTextCheckingResult] {
        guard let phoneNumberRegex = phoneNumberRegex else { return [] }
        return phoneNumberRegex.matchesInString(text, options: [], range: range)
    }
    
}