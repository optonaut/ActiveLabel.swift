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
            if word.hasPrefix("@") {
                let filterResult = extractMention(mentionsArray, word: word, filterPredicate: filterPredicate, type: type, textCount: text.count, match: match)
                word = filterResult.word ?? ""
                id = filterResult.id
                if let index = filterResult.index {
                    mentionsArray?.remove(at: index)
                }
                if let element = filterResult.element, let range = filterResult.range {
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
    
    private static func extractMention(_ mentions: [MentionToPass]?,
                             word: String,
                             filterPredicate: ActiveFilterPredicate?,
                             type: ActiveType,
                             textCount: Int,
                             match: NSTextCheckingResult) -> (word: String?, id: Int?, index: Int?, element: ActiveElement?, range: NSRange?) {
        if let mentionsArray = mentions, let mention = mentionsArray.first(where: {(word.contains($0.name))}) {
            let newId = mention.userId
            let word = mention.name
            let index = mentionsArray.enumerated().first(where: {($0.element == mention)})?.offset
            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word, id: newId)
                var range = NSRange(location: match.range.location, length: word.count + 1)
                if range.location + range.length >= textCount {
                    range = NSRange(location: range.location, length: textCount - range.location)
                }
                return (word: word, id: newId, index: index, element: element, range: range)
            }
            return (word: word, id: newId, index: index, element: nil, range: nil)
        }
        return (word: nil, id: nil, index: nil, element: nil, range: nil)
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
