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
    case DollarSign(String)
    case StringSign(String)
    case None
}

public enum ActiveType {
    case Mention
    case Hashtag
    case URL
    case DollarSign
    case StringSign
    case None
}

typealias ActiveFilterPredicate = (String -> Bool)

struct ActiveBuilder {
    
    static func createMentionElements(fromText text: String, range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [(range: NSRange, element: ActiveElement)] {
        let mentions = RegexParser.getMentions(fromText: text, range: range)
        let nsstring = text as NSString
        var elements: [(range: NSRange, element: ActiveElement)] = []
        
        for mention in mentions where mention.range.length > 2 {
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
    
    static func createHashtagElements(fromText text: String, range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [(range: NSRange, element: ActiveElement)] {
        let hashtags = RegexParser.getHashtags(fromText: text, range: range)
        let nsstring = text as NSString
        var elements: [(range: NSRange, element: ActiveElement)] = []
        
        for hashtag in hashtags where hashtag.range.length > 2 {
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
    
    static func createURLElements(fromText text: String, range: NSRange) -> [(range: NSRange, element: ActiveElement)] {
        let urls = RegexParser.getURLs(fromText: text, range: range)
        let nsstring = text as NSString
        var elements: [(range: NSRange, element: ActiveElement)] = []
        
        for url in urls where url.range.length > 2 {
            let word = nsstring.substringWithRange(url.range)
                .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let element = ActiveElement.URL(word)
            elements.append((url.range, element))
        }
        return elements
    }
    
    static func createDollarSignElements(fromText text: String, range: NSRange) -> [(range: NSRange, element: ActiveElement)] {
        let dolars = RegexParser.getDollarSign(fromText: text, range: range)
        let nsstring = text as NSString
        var elements: [(range: NSRange, element: ActiveElement)] = []
        
        for dolar in dolars where dolar.range.length > 2 {
            let range = NSRange(location: dolar.range.location + 1, length: dolar.range.length - 1)
            var word = nsstring.substringWithRange(range)
            if word.hasPrefix("$") {
                word.removeAtIndex(word.startIndex)
            }
            let element = ActiveElement.DollarSign(word)
            elements.append((dolar.range, element))
        }
        
        return elements
    }
    
    static func createStringSignElements(fromText text: String, range: NSRange, word: String) -> [(range: NSRange, element: ActiveElement)] {
        let strings = RegexParser.getStringSign(fromText: text, range: range, word: word)
        let nsstring = text as NSString
        var elements: [(range: NSRange, element: ActiveElement)] = []
        
        for str in strings where str.range.length > 2 {
            let element = ActiveElement.StringSign(word)
            elements.append((str.range, element))
        }
        
        return elements
    }
    
}
