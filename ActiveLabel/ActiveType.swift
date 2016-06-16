//
//  ActiveType.swift
//  ActiveLabel
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import Foundation

enum ActiveElement {
    case Mention(String)
    case Hashtag(String)
    case URL(String)
    case Phone(String)
    case None
}

public enum ActiveType {
    case Mention
    case Hashtag
    case URL
    case Phone
    case None
}

typealias ActiveFilterPredicate = (String -> Bool)

struct ActiveBuilder {
    
    static func createMentionElements(fromText text: String, range: NSRange, regex: NSRegularExpression?, filterPredicate: ActiveFilterPredicate?) -> [(range: NSRange, element: ActiveElement)] {
        let mentions = RegexParser.getMentions(fromText: text, range: range, regex: regex)
        let nsstring = text as NSString
        var elements: [(range: NSRange, element: ActiveElement)] = []
        
        for mention in mentions where mention.range.length > 1 {
            let range = NSRange(location: mention.range.location + 1, length: mention.range.length - 1)
            var word = nsstring.substringWithRange(range)
            if word.hasPrefix("@") {
                word.removeAtIndex(word.startIndex)
            }

            if filterPredicate?(word) ?? true {
                let element = ActiveElement.Mention(word)
                elements.append((mention.range, element))
            }
        }
        return elements
    }
    
    static func createHashtagElements(fromText text: String, range: NSRange, regex: NSRegularExpression?, filterPredicate: ActiveFilterPredicate?) -> [(range: NSRange, element: ActiveElement)] {
        let hashtags = RegexParser.getHashtags(fromText: text, range: range, regex: regex)
        let nsstring = text as NSString
        var elements: [(range: NSRange, element: ActiveElement)] = []
        
        for hashtag in hashtags where hashtag.range.length > 1 {
            let range = NSRange(location: hashtag.range.location + 1, length: hashtag.range.length - 1)
            var word = nsstring.substringWithRange(range)
            if word.hasPrefix("#") {
                word.removeAtIndex(word.startIndex)
            }

            if filterPredicate?(word) ?? true {
                let element = ActiveElement.Hashtag(word)
                elements.append((hashtag.range, element))
            }
        }
        return elements
    }
    
    static func createURLElements(fromText text: String, range: NSRange, regex: NSRegularExpression?) -> [(range: NSRange, element: ActiveElement)] {
        let urls = RegexParser.getURLs(fromText: text, range: range, regex: regex)
        let nsstring = text as NSString
        var elements: [(range: NSRange, element: ActiveElement)] = []
        
        for url in urls where url.range.length > 1 {
            let word = nsstring.substringWithRange(url.range)
                .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let element = ActiveElement.URL(word)
            elements.append((url.range, element))
        }
        return elements
    }
    
    static func createPhoneNumberElements(fromText text: String, range: NSRange, regex: NSRegularExpression?) -> [(range: NSRange, element: ActiveElement)] {
        let phoneNumbers = RegexParser.getPhoneNumbers(fromText: text, range: range, regex: regex)
        let nsstring = text as NSString
        var elements: [(range: NSRange, element: ActiveElement)] = []
        
        for phoneNumber in phoneNumbers where phoneNumber.range.length > 1 {
            let word = nsstring.substringWithRange(phoneNumber.range)
            let element = ActiveElement.Phone(word)
            elements.append((phoneNumber.range, element))
        }
        return elements
    }
}
