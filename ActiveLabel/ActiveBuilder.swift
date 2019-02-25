//
//  ActiveBuilder.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 04/09/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

typealias ActiveFilterPredicate = ((String) -> Bool)

extension NSAttributedString {
    func replacingOccurrences(of: String, with newString: String) -> NSAttributedString {
        let retValue = NSMutableAttributedString(attributedString: self)
        
        while retValue.string.contains(of) {
            var range = (string as NSString).range(of: of)
            let length = retValue.length
            if (range.location < length - 1) {
                if (range.location + range.length > length) {
                    let delta = length - (range.location + range.length)
                    range.length -= delta
                }
                retValue.replaceCharacters(in: range, with: newString)
            }
        }
        
        return retValue
    }
}

struct ActiveBuilder {

    static func createElements(type: ActiveType, from text: NSAttributedString, range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        switch type {
        case .mention, .hashtag:
            return createElementsIgnoringFirstCharacter(from: text, for: type, range: range, filterPredicate: filterPredicate)
        case .url:
            return createElements(from: text, for: type, range: range, filterPredicate: filterPredicate)
        case .custom:
            return createElements(from: text, for: type, range: range, minLength: 1, filterPredicate: filterPredicate)
        }
    }

    static func createURLElements(from text: NSAttributedString, range: NSRange, maximumLength: Int?) -> ([ElementTuple], NSAttributedString) {
        let type = ActiveType.url
        var text = text
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let plainString = text.string
        let nsstring = plainString as NSString
        var elements: [ElementTuple] = []
        
        typealias URLMatch = (range: NSRange, url: URL?)
        var links: [URLMatch] = []
        text.enumerateAttributes(in: NSRange(location: 0, length: text.length), options: .longestEffectiveRangeNotRequired, using: { (attribute, range, stop) in
            if nil != attribute[.link] {
                links.append(URLMatch(range: range, url: attribute[.link] as? URL))
            }
        })

        for match in matches where match.length > 2 {
            let word = nsstring.substring(with: match)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            guard let maxLength = maximumLength, word.count > maxLength else {
                let range = maximumLength == nil ? match : (plainString as NSString).range(of: word)
                let element = ActiveElement.create(with: type, text: word, link: nil)
                elements.append((range, element, type))
                continue
            }

            let trimmedWord = word.trim(to: maxLength)
            
            text = text.replacingOccurrences(of: word, with: trimmedWord)

            let newRange = (text.string as NSString).range(of: trimmedWord)
            let element = ActiveElement.url(original: word, trimmed: trimmedWord, link: nil)
            elements.append((newRange, element, type))
        }
        
        for link in links {
            let word = nsstring.substring(with: link.range)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            guard let maxLength = maximumLength, word.count > maxLength else {
                let range = maximumLength == nil ? link.range : (plainString as NSString).range(of: word)
                let element = ActiveElement.create(with: type, text: word, link: link.url)
                elements.append((range, element, type))
                continue
            }
            
            let trimmedWord = word.trim(to: maxLength)
            
            text = text.replacingOccurrences(of: word, with: trimmedWord)
            
            let newRange = (text.string as NSString).range(of: trimmedWord)
            let element = ActiveElement.url(original: word, trimmed: trimmedWord, link: link.url)
            elements.append((newRange, element, type))
        }
        
        return (elements, text)
    }

    private static func createElements(from text: NSAttributedString,
                                            for type: ActiveType,
                                                range: NSRange,
                                                minLength: Int = 2,
                                                filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {

        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text.string as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.length > minLength {
            let word = nsstring.substring(with: match)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word, link: nil)
                elements.append((match, element, type))
            }
        }
        return elements
    }

    private static func createElementsIgnoringFirstCharacter(from text: NSAttributedString,
                                                                  for type: ActiveType,
                                                                      range: NSRange,
                                                                      filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text.string as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.length > 2 {
            let range = NSRange(location: match.location + 1, length: match.length - 1)
            var word = nsstring.substring(with: range)
            if word.hasPrefix("@") {
                word.remove(at: word.startIndex)
            }
            else if word.hasPrefix("#") {
                word.remove(at: word.startIndex)
            }

            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word, link: nil)
                elements.append((match, element, type))
            }
        }
        return elements
    }
}
