//
//  ActiveBuilder.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 04/09/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

typealias ActiveFilterPredicate = ((String) -> Bool)

struct ActiveBuilder {

    static func createElements(type: ActiveType, from text: String, range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        switch type {
        case .mention, .hashtag:
            return createElementsIgnoringFirstCharacter(from: text, for: type, range: range, filterPredicate: filterPredicate)
        case .url:
            return createElements(from: text, for: type, range: range, filterPredicate: filterPredicate)
        case .custom:
            return createElements(from: text, for: type, range: range, minLength: 1, filterPredicate: filterPredicate)
        }
    }

    static func createURLElements(from attrString: NSMutableAttributedString, range: NSRange, maximumLenght: Int?) -> [ElementTuple] {
        let type = ActiveType.url
        let originalText = attrString.string
        let matches = RegexParser.getElements(from: originalText, with: type.pattern, range: range)
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > 2 {
            let nsstring = originalText as NSString
            let (word, trimmedRange) = findTrimmedString(from: nsstring, range: match.range)

            guard let maxLenght = maximumLenght, word.characters.count > maxLenght else {
                let range = maximumLenght == nil ? trimmedRange : (attrString.string as NSString).range(of: word)
                let element = ActiveElement.create(with: type, text: word)
                elements.append((range, element, type))
                continue
            }

            let trimmedWord = word.trim(to: maxLenght)
            
            let currentRange = (attrString.string as NSString).range(of: word)
            if currentRange.location != NSNotFound {
                attrString.replaceCharacters(in: currentRange, with: trimmedWord)
                let newRange = (attrString.string as NSString).range(of: trimmedWord)
                let element = ActiveElement.url(original: word, trimmed: trimmedWord)
                elements.append((newRange, element, type))
            }
        }
        return elements
    }

    private static func createElements(from text: String,
                                            for type: ActiveType,
                                                range: NSRange,
                                                minLength: Int = 2,
                                                filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {

        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > minLength {
            let (word, trimmedRange) = findTrimmedString(from: nsstring, range: match.range)
            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word)
                elements.append((trimmedRange, element, type))
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
            let (_, trimmedRange) = findTrimmedString(from: nsstring, range: match.range)
            let range = NSRange(location: trimmedRange.location + 1, length: trimmedRange.length - 1)
            var word = nsstring.substring(with: range)
            if word.hasPrefix("@") {
                word.remove(at: word.startIndex)
            }
            else if word.hasPrefix("#") {
                word.remove(at: word.startIndex)
            }

            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word)
                elements.append((trimmedRange, element, type))
            }
        }
        return elements
    }
    
    
    /// Finds the trimmed substring within the given range of the given string.
    ///
    /// - Parameters:
    ///   - string: original stirng
    ///   - range: range in which it looks it trims the string
    /// - Returns: (trimmed substring, range of the trimmed substring wrt the input string)
    private static func findTrimmedString(from string: NSString, range: NSRange) -> (String, NSRange) {
        let trimmed = string.substring(with: range).trimmingCharacters(in: .whitespacesAndNewlines)
        let range = string.range(of: trimmed)
        return (trimmed, range)
    }
}
