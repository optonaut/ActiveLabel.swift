//
//  ActiveLabel.swift
//  ActiveLabel
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import Foundation
import UIKit

public class ActiveLabel: UILabel {
    
    public var mentionEnabled: Bool = true
    public var hashtagEnabled: Bool = true
    public var URLEnabled: Bool = true
    
    public var mentionColor: UIColor = .blueColor()
    public var hashtagColor: UIColor = .blueColor()
    public var ULRColor: UIColor = .blueColor()
    
    public var handleMentionTap: ((String) -> ())?
    public var handleHashtagTap: ((String) -> ())?
    public var handleURLTap: ((NSURL) -> ())?
    
}