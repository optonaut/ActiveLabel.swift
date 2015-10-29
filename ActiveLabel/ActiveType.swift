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
    
    if let regex = regex where regexMatches(regex, searchString: word)?.isEmpty == false {
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
    
    let pattern = "^[a-z0-9_\\u4e00-\\u9fa5]*"
    
    //if support chinese let pattern = "^[a-z0-9_\\u4e00-\\u9fa5]*" 
    let nsStr = str as NSString
    
    if let result = regexMatches(pattern, searchString: str)?.map({ nsStr.substringWithRange($0.range)}).first {
        if !result.isEmpty {
            return result
        }
    }
    return nil
}


private func regexMatches(regexString: String, searchString: String) -> Array<NSTextCheckingResult>? {
    guard let regex = try? NSRegularExpression(pattern: regexString, options: .CaseInsensitive) else { return nil }
    return regex.matchesInString(searchString, options: [], range: NSMakeRange(0, searchString.characters.count))
}
