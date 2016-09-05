//
//  ActiveLabel.swift
//  ActiveLabel
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import Foundation
import UIKit

public protocol ActiveLabelDelegate: class {
    func didSelectText(text: String, type: ActiveType)
}

typealias ElementTuple = (range: NSRange, element: ActiveElement, type: ActiveType)

@IBDesignable public class ActiveLabel: UILabel {

    // MARK: - public properties
    public weak var delegate: ActiveLabelDelegate?

    public var enabledTypes: [ActiveType] = [.Mention, .Hashtag, .URL]

    public var urlMaximumLength: Int?

    @IBInspectable public var mentionColor: UIColor = .blueColor() {
        didSet { updateTextStorage(parseText: false) }
    }
    @IBInspectable public var mentionSelectedColor: UIColor? {
        didSet { updateTextStorage(parseText: false) }
    }
    @IBInspectable public var hashtagColor: UIColor = .blueColor() {
        didSet { updateTextStorage(parseText: false) }
    }
    @IBInspectable public var hashtagSelectedColor: UIColor? {
        didSet { updateTextStorage(parseText: false) }
    }
    @IBInspectable public var URLColor: UIColor = .blueColor() {
        didSet { updateTextStorage(parseText: false) }
    }
    @IBInspectable public var URLSelectedColor: UIColor? {
        didSet { updateTextStorage(parseText: false) }
    }
    public var customColor: [ActiveType : UIColor] = [:] {
        didSet { updateTextStorage(parseText: false) }
    }
    public var customSelectedColor: [ActiveType : UIColor] = [:] {
        didSet { updateTextStorage(parseText: false) }
    }
    @IBInspectable public var lineSpacing: Float = 0 {
        didSet { updateTextStorage(parseText: false) }
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

    public func handleCustomTap(for type: ActiveType, handler: (String) -> ()) {
        customTapHandlers[type] = handler
    }

    public func filterMention(predicate: (String) -> Bool) {
        mentionFilterPredicate = predicate
        updateTextStorage()
    }

    public func filterHashtag(predicate: (String) -> Bool) {
        hashtagFilterPredicate = predicate
        updateTextStorage()
    }

    // MARK: - override UILabel properties
    override public var text: String? {
        didSet { updateTextStorage() }
    }

    override public var attributedText: NSAttributedString? {
        didSet { updateTextStorage() }
    }

    override public var font: UIFont! {
        didSet { updateTextStorage(parseText: false) }
    }

    override public var textColor: UIColor! {
        didSet { updateTextStorage(parseText: false) }
    }

    override public var textAlignment: NSTextAlignment {
        didSet { updateTextStorage(parseText: false)}
    }

    public override var numberOfLines: Int {
        didSet { textContainer.maximumNumberOfLines = numberOfLines }
    }

    public override var lineBreakMode: NSLineBreakMode {
        didSet { textContainer.lineBreakMode = lineBreakMode }
    }

    // MARK: - init functions
    override public init(frame: CGRect) {
        super.init(frame: frame)
        _customizing = false
        setupLabel()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _customizing = false
        setupLabel()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        updateTextStorage()
    }

    public override func drawTextInRect(rect: CGRect) {
        let range = NSRange(location: 0, length: textStorage.length)

        textContainer.size = rect.size
        let newOrigin = textOrigin(inRect: rect)

        layoutManager.drawBackgroundForGlyphRange(range, atPoint: newOrigin)
        layoutManager.drawGlyphsForGlyphRange(range, atPoint: newOrigin)
    }


    // MARK: - customzation
    public func customize(block: (label: ActiveLabel) -> ()) -> ActiveLabel {
        _customizing = true
        block(label: self)
        _customizing = false
        updateTextStorage()
        return self
    }

    // MARK: - Auto layout
    public override func intrinsicContentSize() -> CGSize {
        let superSize = super.intrinsicContentSize()
        textContainer.size = CGSize(width: superSize.width, height: CGFloat.max)
        let size = layoutManager.usedRectForTextContainer(textContainer)
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }

    // MARK: - touch events
    func onTouch(touch: UITouch) -> Bool {
        let location = touch.locationInView(self)
        var avoidSuperCall = false

        switch touch.phase {
        case .Began, .Moved:
            if let element = elementAtLocation(location) {
                if element.range.location != selectedElement?.range.location || element.range.length != selectedElement?.range.length {
                    updateAttributesWhenSelected(false)
                    selectedElement = element
                    updateAttributesWhenSelected(true)
                }
                avoidSuperCall = true
            } else {
                updateAttributesWhenSelected(false)
                selectedElement = nil
            }
        case .Ended:
            guard let selectedElement = selectedElement else { return avoidSuperCall }

            switch selectedElement.element {
            case .Mention(let userHandle): didTapMention(userHandle)
            case .Hashtag(let hashtag): didTapHashtag(hashtag)
            case .URL(let originalURL, _): didTapStringURL(originalURL)
            case .Custom(let element): didTap(element, for: selectedElement.type)
            }

            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue()) {
                self.updateAttributesWhenSelected(false)
                self.selectedElement = nil
            }
            avoidSuperCall = true
        case .Cancelled:
            updateAttributesWhenSelected(false)
            selectedElement = nil
        case .Stationary:
            break
        }

        return avoidSuperCall
    }

    // MARK: - private properties
    private var _customizing: Bool = true
    private var defaultCustomColor: UIColor = .blackColor()

    private var mentionTapHandler: ((String) -> ())?
    private var hashtagTapHandler: ((String) -> ())?
    private var urlTapHandler: ((NSURL) -> ())?
    private var customTapHandlers: [ActiveType : ((String) -> ())] = [:]

    private var mentionFilterPredicate: ((String) -> Bool)?
    private var hashtagFilterPredicate: ((String) -> Bool)?

    private var selectedElement: ElementTuple?
    private var heightCorrection: CGFloat = 0
    private lazy var textStorage = NSTextStorage()
    private lazy var layoutManager = NSLayoutManager()
    private lazy var textContainer = NSTextContainer()
    lazy var activeElements = [ActiveType: [ElementTuple]]()

    // MARK: - helper functions
    private func setupLabel() {
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        userInteractionEnabled = true
    }

    private func updateTextStorage(parseText parseText: Bool = true) {
        if _customizing { return }
        // clean up previous active elements
        guard let attributedText = attributedText where attributedText.length > 0 else {
            clearActiveElements()
            textStorage.setAttributedString(NSAttributedString())
            setNeedsDisplay()
            return
        }

        let mutAttrString = addLineBreak(attributedText)

        if parseText {
            clearActiveElements()
            let newString = parseTextAndExtractActiveElements(mutAttrString)
            mutAttrString.mutableString.setString(newString)
        }

        addLinkAttribute(mutAttrString)
        textStorage.setAttributedString(mutAttrString)
        _customizing = true
        text = mutAttrString.string
        _customizing = false
        setNeedsDisplay()
    }

    private func clearActiveElements() {
        selectedElement = nil
        for (type, _) in activeElements {
            activeElements[type]?.removeAll()
        }
    }

    private func textOrigin(inRect rect: CGRect) -> CGPoint {
        let usedRect = layoutManager.usedRectForTextContainer(textContainer)
        heightCorrection = (rect.height - usedRect.height)/2
        let glyphOriginY = heightCorrection > 0 ? rect.origin.y + heightCorrection : rect.origin.y
        return CGPoint(x: rect.origin.x, y: glyphOriginY)
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
            case .Custom: attributes[NSForegroundColorAttributeName] = customColor[type] ?? defaultCustomColor
            }

            for element in elements {
                mutAttrString.setAttributes(attributes, range: element.range)
            }
        }
    }

    /// use regex check all link ranges
    private func parseTextAndExtractActiveElements(attrString: NSMutableAttributedString) -> String {
        var textString = attrString.string
        var textLength = textString.utf16.count
        var textRange = NSRange(location: 0, length: textLength)

        if enabledTypes.contains(.URL) {
            let tuple = ActiveBuilder.createURLElements(from: textString, range: textRange, maximumLenght: urlMaximumLength)
            let urlElements = tuple.0
            let finalText = tuple.1
            textString = finalText
            textLength = textString.utf16.count
            textRange = NSRange(location: 0, length: textLength)
            activeElements[.URL] = urlElements
        }

        for type in enabledTypes where type != .URL{
            var filter: ((String) -> Bool)? = nil
            if type == .Mention {
                filter = mentionFilterPredicate
            } else if type == .Hashtag {
                filter = hashtagFilterPredicate
            }
            let hashtagElements = ActiveBuilder.createElements(type, from: textString, range: textRange, filterPredicate: filter)
            activeElements[type] = hashtagElements
        }

        return textString
    }


    /// add line break mode
    private func addLineBreak(attrString: NSAttributedString) -> NSMutableAttributedString {
        let mutAttrString = NSMutableAttributedString(attributedString: attrString)

        var range = NSRange(location: 0, length: 0)
        var attributes = mutAttrString.attributesAtIndex(0, effectiveRange: &range)

        let paragraphStyle = attributes[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineSpacing = CGFloat(lineSpacing)

        attributes[NSParagraphStyleAttributeName] = paragraphStyle
        mutAttrString.setAttributes(attributes, range: range)

        return mutAttrString
    }

    private func updateAttributesWhenSelected(isSelected: Bool) {
        guard let selectedElement = selectedElement else {
            return
        }

        var attributes = textStorage.attributesAtIndex(0, effectiveRange: nil)
        let type = selectedElement.type

        if isSelected {
            let selectedColor: UIColor
            switch type {
            case .Mention: selectedColor = mentionSelectedColor ?? mentionColor
            case .Hashtag: selectedColor = hashtagSelectedColor ?? hashtagColor
            case .URL: selectedColor = URLSelectedColor ?? URLColor
            case .Custom:
                let possibleSelectedColor = customSelectedColor[selectedElement.type] ?? customColor[selectedElement.type]
                selectedColor = possibleSelectedColor ?? defaultCustomColor
            }
            attributes[NSForegroundColorAttributeName] = selectedColor
        } else {
            let unselectedColor: UIColor
            switch type {
            case .Mention: unselectedColor = mentionColor
            case .Hashtag: unselectedColor = hashtagColor
            case .URL: unselectedColor = URLColor
            case .Custom: unselectedColor = customColor[selectedElement.type] ?? defaultCustomColor
            }
            attributes[NSForegroundColorAttributeName] = unselectedColor
        }

        textStorage.addAttributes(attributes, range: selectedElement.range)

        setNeedsDisplay()
    }

    private func elementAtLocation(location: CGPoint) -> ElementTuple? {
        guard textStorage.length > 0 else {
            return nil
        }

        var correctLocation = location
        correctLocation.y -= heightCorrection
        let boundingRect = layoutManager.boundingRectForGlyphRange(NSRange(location: 0, length: textStorage.length), inTextContainer: textContainer)
        guard boundingRect.contains(correctLocation) else {
            return nil
        }

        let index = layoutManager.glyphIndexForPoint(correctLocation, inTextContainer: textContainer)

        for element in activeElements.map({ $0.1 }).flatten() {
            if index >= element.range.location && index <= element.range.location + element.range.length {
                return element
            }
        }

        return nil
    }


    //MARK: - Handle UI Responder touches
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesBegan(touches, withEvent: event)
    }

    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesMoved(touches, withEvent: event)
    }

    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        guard let touch = touches?.first else { return }
        onTouch(touch)
        super.touchesCancelled(touches, withEvent: event)
    }

    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesEnded(touches, withEvent: event)
    }

    //MARK: - ActiveLabel handler
    private func didTapMention(username: String) {
        guard let mentionHandler = mentionTapHandler else {
            delegate?.didSelectText(username, type: .Mention)
            return
        }
        mentionHandler(username)
    }

    private func didTapHashtag(hashtag: String) {
        guard let hashtagHandler = hashtagTapHandler else {
            delegate?.didSelectText(hashtag, type: .Hashtag)
            return
        }
        hashtagHandler(hashtag)
    }

    private func didTapStringURL(stringURL: String) {
        guard let urlHandler = urlTapHandler, let url = NSURL(string: stringURL) else {
            delegate?.didSelectText(stringURL, type: .URL)
            return
        }
        urlHandler(url)
    }

    private func didTap(element: String, for type: ActiveType) {
        guard let elementHandler = customTapHandlers[type] else {
            delegate?.didSelectText(element, type: type)
            return
        }
        elementHandler(element)
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
