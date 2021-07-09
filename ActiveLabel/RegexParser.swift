//
//  RegexParser.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 06/01/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

protocol RegexParserInterface {
    func getElements(from text: String, with pattern: ActiveType, range: NSRange) -> [NSTextCheckingResult]
}

final class RegexParser: RegexParserInterface {

    private let hashtagPattern = "(?:^|\\s|$)#[\\p{L}0-9_]*"
    private let mentionPattern = "(?:^|\\s|$|[.])@[\\p{L}0-9_]*"
    private let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    private let urlPattern = "(^|[\\s.:;?\\-\\]<\\(])" +
        "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
    "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"
    
    /** Global cache that stores all the shared regexes across all of the ActiveLabel instances
        we need to share them across different ActiveLabels because creating new NSRegularExpression and NSDataDetector objects is expensive and we want  to reuse them instead.
     */
    private static var cachedRegularExpressions: [ActiveType : NSRegularExpression] = [:]

    func getElements(from text: String, with pattern: ActiveType, range: NSRange) -> [NSTextCheckingResult] {
        guard let regexForElement = getRegex(forActiveType: pattern) else { return [] }
        return regexForElement.matches(in: text, options: [], range: range)
    }

    private func getRegex(forActiveType activeType: ActiveType) -> NSRegularExpression? {
        // TODO: UT the equality of two custom patterns
        if let cachedRegex = RegexParser.cachedRegularExpressions[activeType] {
            return cachedRegex
        }
        
        var regularExpression: NSRegularExpression?
        
        switch activeType {
        case .phone:
            regularExpression = buildDataDetector(forTypes: [.phoneNumber])
        case .address:
            regularExpression = buildDataDetector(forTypes: [.address])
        case .date:
            regularExpression = buildDataDetector(forTypes: [.date])
        case .url:
            regularExpression = buildRegularExpression(forPattern: urlPattern)
        case .email:
            regularExpression = buildRegularExpression(forPattern: emailPattern)
        case .mention:
            regularExpression = buildRegularExpression(forPattern: mentionPattern)
        case .hashtag:
            regularExpression = buildRegularExpression(forPattern: hashtagPattern)
        case .custom(pattern: let pattern):
            regularExpression = buildRegularExpression(forPattern: pattern)
        }
        
        RegexParser.cachedRegularExpressions[activeType] = regularExpression
        
        return regularExpression
    }
    
    private func buildRegularExpression(forPattern pattern: String) -> NSRegularExpression? {
        return try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    }
    
    private func buildDataDetector(forTypes types: NSTextCheckingResult.CheckingType) -> NSDataDetector? {
        return try? NSDataDetector(types: types.rawValue)
    }
}
