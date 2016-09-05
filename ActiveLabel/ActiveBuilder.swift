//
//  ActiveBuilder.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 04/09/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

typealias ActiveFilterPredicate = (String -> Bool)

struct ActiveBuilder {

    static func createElements(type: ActiveType, from text: String, range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        switch type {
        case .Mention, .Hashtag:
            return createElementsIgnoringFirstCharacter(from: text, for: type, range: range, filterPredicate: filterPredicate)
        case .URL:
            return createElements(from: text, for: type, range: range, filterPredicate: filterPredicate)
        case .Custom:
            return createElements(from: text, for: type, range: range, minLength: 1, filterPredicate: filterPredicate)
        }
    }

    static func createURLElements(from text: String, range: NSRange, maximumLenght: Int?) -> ([ElementTuple], String) {
        let type = ActiveType.URL
        var text = text
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > 2 {
            let word = nsstring.substringWithRange(match.range)
                .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

            guard let maxLenght = maximumLenght where word.characters.count > maxLenght else {
                let range = maximumLenght == nil ? match.range : (text as NSString).rangeOfString(word)
                let element = ActiveElement.create(with: type, text: word)
                elements.append((range, element, type))
                continue
            }

            let trimmedWord = word.trim(to: maxLenght)
            text = text.stringByReplacingOccurrencesOfString(word, withString: trimmedWord)

            let newRange = (text as NSString).rangeOfString(trimmedWord)
            let element = ActiveElement.URL(original: word, trimmed: trimmedWord)
            elements.append((newRange, element, type))
        }
        return (elements, text)
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
