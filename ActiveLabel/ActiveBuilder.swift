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
    
    static func createElements(type: ActiveType, from text: String, range: NSRange, filterPredicate: ActiveFilterPredicate?, mentionsArray: [MentionToPass]?) -> [ElementTuple] {
        switch type {
        case .mention, .hashtag:
            return createElementsIgnoringFirstCharacter(from: text, for: type, range: range, filterPredicate: filterPredicate)
        case .url:
            return createElements(from: text, for: type, range: range, filterPredicate: filterPredicate, mentions: mentionsArray )
        case .custom:
            return createElements(from: text, for: type, range: range, minLength: 1, filterPredicate: filterPredicate, mentions: mentionsArray)
        }
    }

    static func createURLElements(from text: String, range: NSRange, maximumLenght: Int?) -> ([ElementTuple], String) {
        let type = ActiveType.url
        var text = text
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > 2 {
            let word = nsstring.substring(with: match.range)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            guard let maxLenght = maximumLenght, word.characters.count > maxLenght else {
                let range = maximumLenght == nil ? match.range : (text as NSString).range(of: word)
                let element = ActiveElement.create(with: type, text: word)
                elements.append((range, element, type))
                continue
            }

            let trimmedWord = word.trim(to: maxLenght)
            text = text.replacingOccurrences(of: word, with: trimmedWord)

            let newRange = (text as NSString).range(of: trimmedWord)
            let element = ActiveElement.url(original: word, trimmed: trimmedWord)
            elements.append((newRange, element, type))
        }
        return (elements, text)
    }

    private static func createElements(from text: String,
                                       for type: ActiveType,
                                       range: NSRange,
                                       minLength: Int = 2,
                                       filterPredicate: ActiveFilterPredicate?,
                                       mentions: [MentionToPass]?) -> [ElementTuple]{
        
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []
        var mentionsArray = mentions
        for match in matches where match.range.length > minLength {
            var word = nsstring.substring(with: match.range)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            var id: Int? = nil
            if word.hasPrefix("@"), let mentionsArrayUnwrapped = mentionsArray, let mention = mentionsArrayUnwrapped.first(where: {(word.contains($0.name))}) {
                word = mention.name
                id = mention.userId
                for (index, mentionIdentified) in mentionsArrayUnwrapped.enumerated() {
                    if mentionIdentified == mention {
                        mentionsArray!.remove(at: index)
                        break
                    }
                }
                if filterPredicate?(word) ?? true {
                    let element = ActiveElement.create(with: type, text: word, id: id)
                    var range = NSRange(location: match.range.location, length: word.count + 1)
                    if range.location + range.length >= text.count {
                        range = NSRange(location: range.location, length: text.count - range.location)
                    }
                    elements.append((range, element, type))
                }
            } else {
                if word.hasPrefix("#"), filterPredicate?(word) ?? true {
                    let element = ActiveElement.create(with: type, text: word, id: id)
                    elements.append((match.range, element, type))
                }
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
            var word = nsstring.substring(with: range)
            if word.hasPrefix("@") || word.hasPrefix("#") {
                word.remove(at: word.startIndex)
            }
            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }
}
