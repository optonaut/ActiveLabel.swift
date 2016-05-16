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
  case CustomExpression(text: String, identifier: String)
  case None
}

public enum ActiveType {
  case Mention
  case Hashtag
  case URL
  case CustomExpression
  case None

  func createElement(word: String, identifier: String = "") -> ActiveElement {
    switch self {
    case .Mention: return .Mention(word)
    case .Hashtag: return .Hashtag(word)
    case .URL: return .URL(word)
    case .CustomExpression: return .CustomExpression(text: word, identifier: identifier)
    default: return .None
    }
  }
}