//
//  ViewController.swift
//  ActiveLabelDemo
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import UIKit
import ActiveLabel

private extension StringProtocol where Index == String.Index {
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}

class ViewController: UIViewController {
    
    let label = ActiveLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let customType = ActiveType.custom(pattern: "\\sare\\b") //Looks for "are"
        let customType2 = ActiveType.custom(pattern: "\\sit\\b") //Looks for "it"
        let customType3 = ActiveType.custom(pattern: "\\ssupports\\b") //Looks for "supports"

        label.enabledTypes.append(customType)
        label.enabledTypes.append(customType2)
        label.enabledTypes.append(customType3)

        label.urlMaximumLength = 31

        label.customize { label in
            let font = UIFont.systemFont(ofSize: 17)
            let boldFont = UIFont.boldSystemFont(ofSize: 18)

            let plainString = "This is a post with #multiple #hashtags and a @userhandle. Links are also supported like" +
                " this one: http://optonaut.co. Now it also supports custom patterns -> are\n\n" +
            "Let's trim a long link: \nhttps://twitter.com/twicket_app/status/649678392372121601"
            let attrText = NSMutableAttributedString(string: plainString,
                                                      attributes: [.font: font, .foregroundColor: UIColor.orange])
            attrText.addAttributes([.font: boldFont, .foregroundColor: UIColor.magenta], range: NSRange(location: 1, length: 2))
            let wholeRange = plainString.startIndex..<plainString.endIndex
            let link1Range = plainString.range(of: "http://optonaut.co", options: .literal, range: wholeRange, locale: nil)
            let link2Range = plainString.range(of: "https://twitter.com/twicket_app/status/649678392372121601", options: .literal, range: wholeRange, locale: nil)
            attrText.addAttribute(.link, value: "http://optonaut.co", range: plainString.nsRange(from: link1Range!))
            attrText.addAttribute(.link, value: "https://twitter.com/twicket_app/status/649678392372121601", range: plainString.nsRange(from: link2Range!))
            
            
            label.attributedText = attrText
            
            label.numberOfLines = 0
            label.lineSpacing = 4
            
            label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
            label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
            label.mentionColor = UIColor(red: 238.0/255, green: 85.0/255, blue: 96.0/255, alpha: 1)
            label.URLColor = UIColor(red: 85.0/255, green: 238.0/255, blue: 151.0/255, alpha: 1)
            label.URLSelectedColor = UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)

            label.handleMentionTap { self.alert("Mention", message: $0) }
            label.handleHashtagTap { self.alert("Hashtag", message: $0) }
            label.handleURLTap { self.alert("URL", message: $0.absoluteString) }

            //Custom types

            label.customColor[customType] = UIColor.purple
            label.customSelectedColor[customType] = UIColor.green
            label.customColor[customType2] = UIColor.magenta
            label.customSelectedColor[customType2] = UIColor.green
            
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                switch type {
                case customType3:
                    atts[NSAttributedStringKey.font] = isSelected ? UIFont.boldSystemFont(ofSize: 16) : UIFont.boldSystemFont(ofSize: 14)
                default: ()
                }
                
                return atts
            }

            label.handleCustomTap(for: customType) { self.alert("Custom type", message: $0) }
            label.handleCustomTap(for: customType2) { self.alert("Custom type", message: $0) }
            label.handleCustomTap(for: customType3) { self.alert("Custom type", message: $0) }
        }

        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            label.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 24),
        ])
    }
    
    func alert(_ title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        vc.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
    }
}


extension String {
    var html2Attributed: NSAttributedString? {
        do {
            guard let data = data(using: String.Encoding.utf8) else {
                return nil
            }
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
}
