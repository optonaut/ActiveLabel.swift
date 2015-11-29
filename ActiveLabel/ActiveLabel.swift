//
//  ActiveLabel.swift
//  ActiveLabel
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import Foundation
import UIKit

public typealias ActiveElement = (range:NSRange, element: ActiveRegex, text: String)

public struct ActiveRegex {
    
    public var key:String?
    public var regex:String?
    public var textColor:UIColor?
    public var tapHandler: (ActiveElement -> ())?
    public var highlightColor:UIColor?
    
    public init() {
    
    }
    
}

@IBDesignable public class ActiveLabel: UILabel {
    

    // MARK: - public properties
    @IBInspectable public var mentionEnabled: Bool = true {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var hashtagEnabled: Bool = true {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var URLEnabled: Bool = true {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var mentionColor: UIColor = .blueColor() {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var mentionSelectedColor: UIColor? {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var hashtagColor: UIColor = .blueColor() {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var hashtagSelectedColor: UIColor? {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var URLColor: UIColor = .blueColor() {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var URLSelectedColor: UIColor? {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var lineSpacing: Float? {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var activeBackgroundColor: UIColor? {
        didSet {
            updateTextStorage()
        }
    }
    
    // MARK: - public methods
    public func handleMentionTap(handler: (ActiveElement) -> ()) {
        mentionTapHandler = handler
    }
    
    public func handleHashtagTap(handler: (ActiveElement) -> ()) {
        hashtagTapHandler = handler
    }
    
    public func handleURLTap(handler: (ActiveElement) -> ()) {
        urlTapHandler = handler
    }
    
    public func handleRegexTap(handler: (ActiveElement) -> ()) {
        regexTapHandler = handler
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
    
    public var extendRegex:Array<ActiveRegex>? {
        didSet {
//            self.setupRegexArray()
        }
    }
    
    private var regexArray:Array<ActiveRegex> = Array()
    
    // MARK: - init functions
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLabel()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupLabel()
    }
    
    public override func drawTextInRect(rect: CGRect) {
        let range = NSRange(location: 0, length: textStorage.length)
        
        textContainer.size = rect.size
        
        layoutManager.drawBackgroundForGlyphRange(range, atPoint: rect.origin)
        layoutManager.drawGlyphsForGlyphRange(range, atPoint: rect.origin)
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        let currentSize = textContainer.size
        defer {
            textContainer.size = currentSize
        }
        
        textContainer.size = size
        return layoutManager.usedRectForTextContainer(textContainer).size
    }
    
    /**
     use touches replace GestureRecognizer ,it can response scrollview event
     
     - parameter touches:
     - parameter event:
     */
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        let touch = (touches.first)!
        let location = touch.locationInView(self)

        if let element = elementAtLocation(location) {
            selectedElement = element
            addHighlightColor(true,active: element)
        } else {
            super.touchesBegan(touches, withEvent: event)
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        guard let selectedElement = selectedElement else {
            return
        }
        
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.20 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            if let selectedElement = self.selectedElement {
                self.addHighlightColor(false,active: selectedElement)
                self.selectedElement = nil
            }
        }
        
        selectedElement.element.tapHandler?(selectedElement)
    }
    
    override public func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.20 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            if let selectedElement = self.selectedElement {
                self.addHighlightColor(false,active: selectedElement)
                self.selectedElement = nil
            }
        }
    }
    
    // MARK: - private properties
    private var mentionTapHandler: ((range:NSRange, element: ActiveRegex, text: String) -> ())?
    private var hashtagTapHandler: ((range:NSRange, element: ActiveRegex, text: String) -> ())?
    private var urlTapHandler: ((range:NSRange, element: ActiveRegex, text: String) -> ())?
    private var regexTapHandler: ((range:NSRange, element: ActiveRegex, text: String) -> ())?
    
    private var selectedElement: (range:NSRange, element: ActiveRegex, text: String)?
    private lazy var textStorage = NSTextStorage()
    private lazy var layoutManager = NSLayoutManager()
    private lazy var textContainer = NSTextContainer()
    
    private lazy var activeElements: [(range:NSRange, element: ActiveRegex, text: String)] = []
    
    
    public func setupRegexArray() {
        
        self.regexArray.removeAll()
        
        var regexType = [
            ["key":"mention","regex":mentionPattern()],
            ["key":"hashTag","regex":hashTagsPattern()],
            ["key":"URL","regex":URLPattern()]
        ]
        
        if !self.mentionEnabled { regexType.removeAtIndex(0) }
        if !self.hashtagEnabled { regexType.removeAtIndex(1) }
        if !self.URLEnabled { regexType.removeAtIndex(2) }

        for type in regexType {
            var regex = ActiveRegex()
            regex.key = type["key"]
            regex.regex = type["regex"]
            switch regex.key! {
            case "mention":
                regex.textColor = self.mentionColor
                regex.tapHandler = self.mentionTapHandler
                regex.highlightColor = self.activeBackgroundColor
            case "hashTag":
                regex.textColor = self.hashtagColor
                regex.tapHandler = self.hashtagTapHandler
                regex.highlightColor = self.activeBackgroundColor
            case "URL":
                regex.textColor = self.URLColor
                regex.tapHandler = self.urlTapHandler
                regex.highlightColor = self.activeBackgroundColor
            default:
                break;
            }
            
            self.regexArray.append(regex)
        }

        if let extend = self.extendRegex {
            self.regexArray += extend
        }
        
        updateTextStorage()
    }
    // MARK: - helper functions
    private func setupLabel() {
        
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0
        setupRegexArray()
        
        userInteractionEnabled = true
    }
    
    private func updateTextStorage() {
        guard let attributedText = attributedText else {
            return
        }
        // clean up previous active elements
        activeElements.removeAll()
        
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
        
        for (range, elements, _) in activeElements {
            attributes[NSForegroundColorAttributeName] = elements.textColor
            mutAttrString.setAttributes(attributes,range: range)
        }
        
    }
    
    /// use regex check all link ranges
    private func parseTextAndExtractActiveElements(attrString: NSAttributedString) {
        
        for activeRegex in regexArray {
            
            if let matchResult = regexMatches(activeRegex.regex!, searchString: attrString.string) {
                
                for match in matchResult {
                    let matchNSString = attrString.string as NSString
                    let text = matchNSString.substringWithRange(match.range)
                    activeElements.append((range: match.range, element: activeRegex,text: text))
                }
            }
        }

    }
    
    /// add line break mode
    private func addLineBreak(attrString: NSAttributedString) -> NSMutableAttributedString {
        let mutAttrString = NSMutableAttributedString(attributedString: attrString)
        
        var range = NSRange(location: 0, length: 0)
        var attributes = mutAttrString.attributesAtIndex(0, effectiveRange: &range)
        
        let paragraphStyle = attributes[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
        if let lineSpacing = lineSpacing {
            paragraphStyle.lineSpacing = CGFloat(lineSpacing)
        }
        
        attributes[NSParagraphStyleAttributeName] = paragraphStyle
        mutAttrString.setAttributes(attributes, range: range)
        
        return mutAttrString
    }
    
    private func addHighlightColor(isHighlight:Bool,active:ActiveElement) {
        
        var attributes = textStorage.attributesAtIndex(0, effectiveRange: nil)
        
        attributes[NSForegroundColorAttributeName] = active.element.textColor
        
        if isHighlight {
            attributes[NSBackgroundColorAttributeName] = active.element.highlightColor ?? UIColor.clearColor()

        } else {
            attributes[NSBackgroundColorAttributeName] = UIColor.clearColor()
        }
        
        textStorage.addAttributes(attributes, range: active.range)
        
        setNeedsDisplay()
    }
    
    
    private func elementAtLocation(location: CGPoint) -> ActiveElement? {
        guard textStorage.length > 0 else {
            return nil
        }
        
        let boundingRect = layoutManager.boundingRectForGlyphRange(NSRange(location: 0, length: textStorage.length), inTextContainer: textContainer)
        guard boundingRect.contains(location) else {
            return nil
        }
        
        let index = layoutManager.glyphIndexForPoint(location, inTextContainer: textContainer)
        
        for element in activeElements {
            if index >= element.0.location && index <= element.0.location + element.0.length {
                return element
            }
        }
        
        return nil
    }
    
    
    private func hashTagsPattern() -> String {
        return "(#[a-zA-Z0-9_\\u4E00-\\u9FA5]+)"
    }
    
    private func mentionPattern() -> String {
        return "(@[a-zA-Z0-9_\\u4E00-\\u9FA5]+)"
    }
    
    private func URLPattern() -> String {
        return "[a-zA-z]+://[^\\s]*"
    }
    
    private func regexMatches(regexString: String, searchString: String) -> Array<NSTextCheckingResult>? {
        guard let regex = try? NSRegularExpression(pattern: regexString, options: .CaseInsensitive) else { return nil }
        return regex.matchesInString(searchString, options: [], range: NSMakeRange(0, searchString.characters.count))
    }
    
}

extension ActiveLabel: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
