//
//  ActiveType.swift
//  ActiveLabel
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import Foundation

enum ActiveType {
    case Mention(String)
    case Hashtag(String)
    case URL(NSURL)
    case None
}

func activeType(word: String) -> ActiveType {
    if word.characters.count < 2 {
        return .None
    }
    
    if word.hasPrefix("@") {
        return .Mention(word.substringFromIndex(word.startIndex.advancedBy(1)))
    } else if word.hasPrefix("#") {
        return .Hashtag(word.substringFromIndex(word.startIndex.advancedBy(1)))
    } else if let url = checkForURL(word) {
        return .URL(url)
    } else {
        return .None
    }
}

private func checkForURL(str: String) -> NSURL? {
    if let regex = try? NSRegularExpression(pattern: "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+", options: [.CaseInsensitive]) {
        if regex.numberOfMatchesInString(str, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, str.characters.count)) == 1 {
            if let url = NSURL(string: str) {
                return url
            }
        }
    }
    return nil
}