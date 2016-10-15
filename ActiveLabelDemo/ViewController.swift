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
    let toggleButton = UIButton(type: .system)
    
    private var usingAttributedText = false
    
    private let defaultText = "This is a post with #multiple #hashtags and a @userhandle. Links are also supported like this one: http://optonaut.co. Now it also supports custom patterns -> are\n\nLet's trim a long link: \nhttps://twitter.com/twicket_app/status/649678392372121601"

    override func viewDidLoad() {
        super.viewDidLoad()

        let customType = ActiveType.custom(pattern: "\\sare\\b") //Looks for "are"
        let customType2 = ActiveType.custom(pattern: "\\sit\\b") //Looks for "it"

        label.enabledTypes.append(customType)
        label.enabledTypes.append(customType2)

        label.urlMaximumLength = 31

        label.customize { label in
            
            label.numberOfLines = 0
            label.lineSpacing = 4
            
            label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
            label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
            label.mentionColor = UIColor(red: 238.0/255, green: 85.0/255, blue: 96.0/255, alpha: 1)
            label.URLColor = UIColor(red: 85.0/255, green: 238.0/255, blue: 151.0/255, alpha: 1)
            label.URLSelectedColor = UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)

            label.handleMentionTap { self.alert(title: "Mention", message: $0) }
            label.handleHashtagTap { self.alert(title: "Hashtag", message: $0) }
            label.handleURLTap { self.alert(title: "URL", message: $0.absoluteString) }

            //Custom types

            label.customColor[customType] = UIColor.purple
            label.customSelectedColor[customType] = UIColor.green
            label.customColor[customType2] = UIColor.magenta
            label.customSelectedColor[customType2] = UIColor.green

            label.handleCustomTap(for: customType) { self.alert(title: "Custom type", message: $0) }
            label.handleCustomTap(for: customType2) { self.alert(title: "Custom type", message: $0) }
        }

        label.frame = CGRect(x: 20, y: 40, width: view.frame.width - 40, height: 300)
        view.addSubview(label)
        
        toggleButton.frame.size = CGSize(width: 200, height: 50)
        toggleButton.center = CGPoint(x: view.bounds.midX, y: view.bounds.maxY - 50)
        view.addSubview(toggleButton)
        toggleButton.addTarget(self, action: #selector(toggleLabelText), for: .touchUpInside)
        
        toggleLabelText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func toggleLabelText() {
        usingAttributedText = !usingAttributedText
    
        if usingAttributedText {
            
            toggleButton.setTitle("Use Text", for: .normal)
            
            let text = NSMutableAttributedString()
            let s1 = NSAttributedString(string: "BIG AND FAT ", attributes: [
                NSForegroundColorAttributeName : UIColor.orange,
                NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline).withSize(30)
                ])
            let s2 = NSAttributedString(string: defaultText, attributes: [
                NSForegroundColorAttributeName : UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1),
                NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
                ])
            text.append(s1)
            text.append(s2)
            label.attributedText = text
            
        } else {
            label.text = defaultText
            
            toggleButton.setTitle("Use Attributed Text", for: .normal)
        }
    }
    
    
    func alert(title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
    }

}

