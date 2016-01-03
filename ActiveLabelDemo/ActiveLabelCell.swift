//
//  ActiveLabelCell.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 03/01/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import UIKit
import ActiveLabel

class ActiveLabelCell: UITableViewCell {
    
    let activeLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.numberOfLines = 0
        label.lineSpacing = 4
        label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
        label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
        label.mentionColor = UIColor(red: 238.0/255, green: 85.0/255, blue: 96.0/255, alpha: 1)
        label.URLColor = UIColor(red: 85.0/255, green: 238.0/255, blue: 151.0/255, alpha: 1)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        activeLabel.frame = contentView.bounds
        activeLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        contentView.addSubview(activeLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Customize
    
    func customizeCell(withText text: String) {
        activeLabel.text = text
        activeLabel.textAlignment = .Center
    }
}