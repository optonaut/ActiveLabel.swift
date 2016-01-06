//
//  ViewController.swift
//  ActiveLabelDemo
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import UIKit
import ActiveLabel

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ActiveLabelDelegate {
    
    let label = ActiveLabel()
    let tableView = UITableView()
    let reuseID = "reuseID"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ActiveLabel.swift"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = self.view.bounds
        tableView.registerClass(ActiveLabelCell.self, forCellReuseIdentifier: reuseID)
        view.addSubview(tableView)
    }
    
    
    //MARK: ActiveLabelDelegate
    
    func didSelectText(text: String, type: ActiveType) {
        switch type {
        case .Mention:
            alert("Mention", message: text)
        case .Hashtag:
            alert("Hashtag", message: text)
        case .URL:
            alert("URL", message: text)
        case .None:
            break
        }
    }
    
    
    //MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let startDate = NSDate()
        guard let cell = tableView.dequeueReusableCellWithIdentifier(reuseID) as? ActiveLabelCell else {
            return UITableViewCell()
        }
        cell.customizeCell(withText: "This is a post with #multiple #hashtags and a @userhandle. Links are also supported like this one: http://optonaut.co." +
        " This is a post with #multiple #hashtags and a @userhandle. Links are also supported like this one: http://optonaut.co.")
        cell.activeLabel.delegate = self
        print("Reuse time = \(NSDate().timeIntervalSinceDate(startDate))")
        return cell
    }
    
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? ActiveLabelCell
        cell?.backgroundColor = .grayColor()
        UIView.animateWithDuration(0.5) { cell?.backgroundColor = .clearColor()}
    }
    
    
    func alert(title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        vc.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        presentViewController(vc, animated: true, completion: nil)
    }

}

