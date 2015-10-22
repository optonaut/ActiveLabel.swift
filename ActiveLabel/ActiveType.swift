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
    case Regex(String)
    case None
}

enum ActiveType {
    case Mention
    case Hashtag
    case URL
    case Regex
    case None
}

func activeElement(word: String, regex: String? = nil) -> ActiveElement {
    if let url = reduceRightToURL(word) {
        return .URL(url)
    }
    
    if (regex != nil && (word=~regex!)?.count > 0) {
        return .Regex(word)
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
    
    let pattern = "^[a-z0-9_]*"
    //if support chinese let pattern = "^[a-z0-9_\\u4e00-\\u9fa5]*" 
    let nsStr = str as NSString
    if let result = (str=~pattern)?.map({ nsStr.substringWithRange($0.range)}).first {
        if !result.isEmpty {
            return result
        }
    }
    return nil
}

private struct RegexHelper {
    let regex: NSRegularExpression
    
    init(_ pattern: String) throws {
        try regex = NSRegularExpression(pattern: pattern,
            options: .CaseInsensitive)
    }
    
    func match(input: String) -> Array<NSTextCheckingResult> {
        let matches = regex.matchesInString(input,
            options: [],
            range: NSMakeRange(0, input.characters.count))
        return matches
    }
}

infix operator =~ {
    associativity none
    precedence 130
}

private func =~(lhs:String, rhs:String) -> Array<NSTextCheckingResult>? {
    do {
        return try RegexHelper(rhs).match(lhs)
    } catch _ {
        return nil
    }
}
