//
//  ViewController.swift
//  ActiveLabelDemo
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import UIKit
import Foundation
import ActiveLabel

class ViewController: UIViewController {

  @IBOutlet weak var label: ActiveLabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    label.customExpressions = [
      CustomExpression(
        regex: "[^\\w#](s[\\w]+)", // any word beginning by s which is not an hashtag
        mapFn: { (result:NSTextCheckingResult) -> NSRange in
          return result.rangeAtIndex(1) // which range would you like to use?
        },
        options: [NSRegularExpressionOptions.CaseInsensitive]) // some optional options for the regular expression
        .identifier("word beginning by 's'") // optional handy identifier
    ]

    // Active label also provides a function to get mentions, URLs, ... from a string without using a ActiveLabel object.
    ActiveLabel.extractAttributesFromString("This is some string with #hashtags, @mentions, @alex, @some-cool-user and an email: alex@jogabo.com.").forEach {
      print("Elements of type:", $0.0)
      $0.1.forEach { elem in
        print(elem.element)
      }
    }
    
    label.handleElementTap {
      print($0)
    }
  }
}
