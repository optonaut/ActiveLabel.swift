//
//  ActiveType.swift
//  ActiveLabel
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import Foundation

public enum ActiveElement {
  case mention(String)
  case hashtag(String)
  case url(String)
  case customExpression(text: String, identifier: String)
  case none
}

public enum ActiveType {
  case mention
  case hashtag
  case url
  case customExpression
  case none

  func createElement(_ word: String, identifier: String = "") -> ActiveElement {
    switch self {
    case .mention: return .mention(word)
    case .hashtag: return .hashtag(word)
    case .url: return .url(word)
    case .customExpression: return .customExpression(text: word, identifier: identifier)
    default: return .none
    }
  }
}
