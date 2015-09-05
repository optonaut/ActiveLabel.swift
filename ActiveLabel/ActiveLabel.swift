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
    
    // MARK: - public properties
    public var mentionEnabled: Bool = true {
        didSet {
            updateTextStorage()
        }
    }
    public var hashtagEnabled: Bool = true {
        didSet {
            updateTextStorage()
        }
    }
    public var URLEnabled: Bool = true {
        didSet {
            updateTextStorage()
        }
    }
    public var mentionColor: UIColor = .blueColor() {
        didSet {
            updateTextStorage()
        }
    }
    public var mentionSelectedColor: UIColor? {
        didSet {
            updateTextStorage()
        }
    }
    public var hashtagColor: UIColor = .blueColor() {
        didSet {
            updateTextStorage()
        }
    }
    public var hashtagSelectedColor: UIColor? {
        didSet {
            updateTextStorage()
        }
    }
    public var URLColor: UIColor = .blueColor() {
        didSet {
            updateTextStorage()
        }
    }
    public var URLSelectedColor: UIColor? {
        didSet {
            updateTextStorage()
        }
    }
    public var lineSpacing: Float? {
        didSet {
            updateTextStorage()
        }
    }
    
    // MARK: - public methods
    public func handleMentionTap(handler: (String) -> ()) {
        mentionTapHandler = handler
    }
    
    public func handleHashtagTap(handler: (String) -> ()) {
        hashtagTapHandler = handler
    }
    
    public func handleURLTap(handler: (NSURL) -> ()) {
        urlTapHandler = handler
    }
    
    // MARK: - override UILabel properties
    override public var text: String? {
        didSet {
            updateTextStorage()
        }
    }
    
    override public var attributedText: NSAttributedString? {
        didSet {
            updateTextStorage()
        }
    }
    
    override public var font: UIFont! {
        didSet {
            updateTextStorage()
        }
    }
    
    override public var textColor: UIColor! {
        didSet {
            updateTextStorage()
        }
    }
    
    // MARK: - init functions
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLabel()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupLabel()
    }
    
    // MARK: - layout functions
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        textContainer.size = bounds.size
    }
    
    public override func drawTextInRect(rect: CGRect) {
        let range = NSRange(location: 0, length: textStorage.length)
        
        layoutManager.drawBackgroundForGlyphRange(range, atPoint: CGPointZero)
        layoutManager.drawGlyphsForGlyphRange(range, atPoint: CGPointZero)
    }
    
    // MARK: - touch events
    func onTouch(gesture: UILongPressGestureRecognizer) {
        let location = gesture.locationInView(self)
        
        switch gesture.state {
        case .Began, .Changed:
            if let element = elementAtLocation(location) {
                if element.range.location != selectedElement?.range.location || element.range.length != selectedElement?.range.length {
                    updateAttributesWhenSelected(false)
                    selectedElement = element
                    updateAttributesWhenSelected(true)
                }
            } else {
                updateAttributesWhenSelected(false)
                selectedElement = nil
            }
        case .Cancelled, .Ended:
            guard let selectedElement = selectedElement else {
                return
            }
            
            switch selectedElement.element {
            case .Mention(let userHandle): mentionTapHandler?(userHandle)
            case .Hashtag(let hashtag): hashtagTapHandler?(hashtag)
            case .URL(let url): urlTapHandler?(url)
            case .None: ()
            }
            
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue()) {
                self.updateAttributesWhenSelected(false)
                self.selectedElement = nil
            }
        default: ()
        }
    }
    
    // MARK: - private properties
    private var mentionTapHandler: ((String) -> ())?
    private var hashtagTapHandler: ((String) -> ())?
    private var urlTapHandler: ((NSURL) -> ())?
    
    private var selectedElement: (range: NSRange, element: ActiveElement)?
    private lazy var textStorage = NSTextStorage()
    private lazy var layoutManager = NSLayoutManager()
    private lazy var textContainer = NSTextContainer()
    private lazy var activeElements: [ActiveType: [(range: NSRange, element: ActiveElement)]] = [
        .Mention: [],
        .Hashtag: [],
        .URL: [],
    ]
    
    // MARK: - helper functions
    private func setupLabel() {
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0
        
        let touchRecognizer = UILongPressGestureRecognizer(target: self, action: "onTouch:")
        touchRecognizer.minimumPressDuration = 0.00001
        addGestureRecognizer(touchRecognizer)
        
        userInteractionEnabled = true
    }
    
    private func updateTextStorage() {
        guard let attributedText = attributedText else {
            return
        }
        
        // clean up previous active elements
        for (type, _) in activeElements {
            activeElements[type]?.removeAll()
        }
        
        guard attributedText.length > 0 else {
            return
        }
        
        let mutAttrString = addLineBreak(attributedText)
        parseTextAndExtractActiveElements(mutAttrString)
        addLinkAttribute(mutAttrString)
        
        textStorage.setAttributedString(mutAttrString)
        
        setNeedsDisplay()
    }
    
    /// add link attribute
    private func addLinkAttribute(mutAttrString: NSMutableAttributedString) {
        var range = NSRange(location: 0, length: 0)
        var attributes = mutAttrString.attributesAtIndex(0, effectiveRange: &range)
        
        attributes[NSFontAttributeName] = font!
        attributes[NSForegroundColorAttributeName] = textColor
        mutAttrString.addAttributes(attributes, range: range)
        
        attributes[NSForegroundColorAttributeName] = mentionColor
        
        for (type, elements) in activeElements {
            
            switch type {
            case .Mention: attributes[NSForegroundColorAttributeName] = mentionColor
            case .Hashtag: attributes[NSForegroundColorAttributeName] = hashtagColor
            case .URL: attributes[NSForegroundColorAttributeName] = URLColor
            case .None: ()
            }
            
            for element in elements {
                mutAttrString.setAttributes(attributes, range: element.range)
            }
        }
    }
    
    /// use regex check all link ranges
    private func parseTextAndExtractActiveElements(attrString: NSAttributedString) {
        let textString = attrString.string as NSString
        for word in textString.componentsSeparatedByString(" ") {
            let element = activeElement(word)
            switch element {
            case .Mention(let userHandle) where mentionEnabled:
                activeElements[.Mention]?.append((textString.rangeOfString("@\(userHandle)"), element))
            case .Hashtag(let hashtag) where hashtagEnabled:
                activeElements[.Hashtag]?.append((textString.rangeOfString("#\(hashtag)"), element))
            case .URL(let url) where URLEnabled:
                activeElements[.URL]?.append((textString.rangeOfString(url.absoluteString), element))
            default: ()
            }
        }
    }
    
    /// add line break mode
    private func addLineBreak(attrString: NSAttributedString) -> NSMutableAttributedString {
        let mutAttrString = NSMutableAttributedString(attributedString: attrString)
        
        var range = NSRange(location: 0, length: 0)
        var attributes = mutAttrString.attributesAtIndex(0, effectiveRange: &range)
        
        let paragraphStyle = attributes[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        if let lineSpacing = lineSpacing {
            paragraphStyle.lineSpacing = CGFloat(lineSpacing)
        }
        
        attributes[NSParagraphStyleAttributeName] = paragraphStyle
        mutAttrString.setAttributes(attributes, range: range)
        
        return mutAttrString
    }
    
    private func updateAttributesWhenSelected(isSelected: Bool) {
        guard let selectedElement = selectedElement else {
            return
        }
        
        var attributes = textStorage.attributesAtIndex(0, effectiveRange: nil)
        if isSelected {
            switch selectedElement.element {
            case .Mention(_): attributes[NSForegroundColorAttributeName] = mentionColor
            case .Hashtag(_): attributes[NSForegroundColorAttributeName] = hashtagColor
            case .URL(_): attributes[NSForegroundColorAttributeName] = URLColor
            case .None: ()
            }
        } else {
            switch selectedElement.element {
            case .Mention(_): attributes[NSForegroundColorAttributeName] = mentionSelectedColor ?? mentionColor
            case .Hashtag(_): attributes[NSForegroundColorAttributeName] = hashtagSelectedColor ?? hashtagColor
            case .URL(_): attributes[NSForegroundColorAttributeName] = URLSelectedColor ?? URLColor
            case .None: ()
            }
        }
        
        textStorage.addAttributes(attributes, range: selectedElement.range)
        
        setNeedsDisplay()
    }
    
    private func elementAtLocation(location: CGPoint) -> (range: NSRange, element: ActiveElement)? {
        guard textStorage.length > 0 else {
            return nil
        }
        
        let boundingRect = layoutManager.boundingRectForGlyphRange(NSRange(location: 0, length: textStorage.length), inTextContainer: textContainer)
        guard boundingRect.contains(location) else {
            return nil
        }
        
        let index = layoutManager.glyphIndexForPoint(location, inTextContainer: textContainer)
        
        for element in activeElements.map({ $0.1 }).flatten() {
            if index >= element.range.location && index <= element.range.location + element.range.length {
                return element
            }
        }
        
        return nil
    }
    
}