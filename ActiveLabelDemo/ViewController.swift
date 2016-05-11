//
//  ViewController.swift
//  ActiveLabelDemo
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import UIKit
import ActiveLabel

class ViewController: UIViewController {

  let label = ActiveLabel()

  override func viewDidLoad() {
    super.viewDidLoad()

    label.text = "This is a post with #multiple #hashtags, and a @userhandle, #COOL. Links are also supported like this one: http://optonaut.co. some test: alex@jogabo.com, hey (@alex)"
    label.numberOfLines = 0
    label.lineSpacing = 4

    label.font = UIFont.systemFontOfSize(30)
    label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
    label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
    label.hashtagHighlightedColor = label.hashtagColor.colorWithAlphaComponent(0.5)
    label.mentionColor = UIColor(red: 238.0/255, green: 85.0/255, blue: 96.0/255, alpha: 1)
    label.mentionHighlightedColor = label.mentionColor.colorWithAlphaComponent(0.5)
    label.URLColor = UIColor(red: 85.0/255, green: 238.0/255, blue: 151.0/255, alpha: 1)
    label.URLHighlightedColor = label.URLColor.colorWithAlphaComponent(0.5)
    label.delegate = self

    label.handleMentionTap { self.alert("Mention", message: $0) }
    label.handleHashtagTap { self.alert("Hashtag", message: $0) }
    label.handleURLTap { self.alert("URL", message: $0.description) }

    label.frame = CGRect(x: 20, y: 40, width: view.frame.width - 40, height: 600)
    view.addSubview(label)
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func alert(title: String, message: String) {
    let vc = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    vc.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
    presentViewController(vc, animated: true, completion: nil)
  }

}

extension ViewController: ActiveLabelDelegate {

  func label(label: ActiveLabel, shouldIgnoreElement element: ActiveElement) -> Bool {
    switch element {
    case .Mention(let username):
      return username == "alex"
    default:
      return false
    }
  }

  func didSelectText(text: String, type: ActiveType) {
    
  }

}

