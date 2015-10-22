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
    case URL(NSURL)
    case CUSTOM(String)
    case None
}

enum ActiveType {
    case Mention
    case Hashtag
    case URL
    case CUSTOM
    case None
}

func activeElement(word: String, matchWord: String = "") -> ActiveElement {
    if let url = reduceRightToURL(word) {
        return .URL(url)
    }
    
    if word == matchWord {
        return .CUSTOM(word)
    }
    
    if word.characters.count < 2 {
        return .None
    }
    
    // remove # or @ sign and reduce to alpha numeric string (also allowed: _)
    guard let allowedWord = reduceRightToAllowed(word.substringFromIndex(word.startIndex.advancedBy(1))) else {
        return .None
    }
    
    if word.hasPrefix("@") {
        return .Mention(allowedWord)
    } else if word.hasPrefix("#") {
        return .Hashtag(allowedWord)
    } else {
        return .None
    }
}

private func reduceRightToURL(str: String) -> NSURL? {
    if let urlDetector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue) {
        let nsStr = str as NSString
        let results = urlDetector.matchesInString(str, options: .ReportCompletion, range: NSRange(location: 0, length: nsStr.length))
        if let result = results.map({ nsStr.substringWithRange($0.range) }).first, url = NSURL(string: result) {
            return url
        }
    }
    return nil
}

private func reduceRightToAllowed(str: String) -> String? {
    if let regex = try? NSRegularExpression(pattern: "^[a-z0-9_]*", options: [.CaseInsensitive]) {
        let nsStr = str as NSString
        let results = regex.matchesInString(str, options: [], range: NSRange(location: 0, length: nsStr.length))
        if let result = results.map({ nsStr.substringWithRange($0.range) }).first {
            if !result.isEmpty {
                return result
            }
        }
    }
    return nil
}