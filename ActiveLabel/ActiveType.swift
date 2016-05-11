//
//  ActiveType.swift
//  ActiveLabel
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import Foundation

public enum ActiveElement {
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

  func createElement(word: String) -> ActiveElement {
    switch self {
    case .Mention: return .Mention(word)
    case .Hashtag: return .Hashtag(word)
    case .URL: return .URL(word)
    default: return .None
    }
  }
}