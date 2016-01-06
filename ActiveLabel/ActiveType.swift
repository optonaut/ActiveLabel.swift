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
    case None
}

public enum ActiveType {
    case Mention
    case Hashtag
    case URL
    case None
}

struct ActiveBuilder {
    
    static func createMentionElements(fromText text: String, range: NSRange) -> [(range: NSRange, element: ActiveElement)] {
        let mentions = RegexParser.getMentions(fromText: text, range: range)
        let nsstring = text as NSString
        var elements: [(range: NSRange, element: ActiveElement)] = []
        
        for mention in mentions where mention.range.length > 2 {
            let word = nsstring.substringWithRange(mention.range)
            let element = ActiveElement.Mention(word)
            elements.append((mention.range, element))
        }
        return elements
    }
    
    static func createHashtagElements(fromText text: String, range: NSRange) -> [(range: NSRange, element: ActiveElement)] {
        let hashtags = RegexParser.getHashtags(fromText: text, range: range)
        let nsstring = text as NSString
        var elements: [(range: NSRange, element: ActiveElement)] = []
        
        for hashtag in hashtags where hashtag.range.length > 2 {
            let word = nsstring.substringWithRange(hashtag.range)
            let element = ActiveElement.Hashtag(word)
            elements.append((hashtag.range, element))
        }
        return elements
    }
    
    static func createURLElements(fromText text: String, range: NSRange) -> [(range: NSRange, element: ActiveElement)] {
        let urls = RegexParser.getURLs(fromText: text, range: range)
        let nsstring = text as NSString
        var elements: [(range: NSRange, element: ActiveElement)] = []
        
        for url in urls where url.range.length > 2 {
            let word = nsstring.substringWithRange(url.range)
            let element = ActiveElement.URL(word)
            elements.append((url.range, element))
        }
        return elements
    }
}
