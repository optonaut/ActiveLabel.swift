//
//  ActiveLabel.swift
//  ActiveLabel
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import Foundation
import UIKit

public extension String {
  
  public subscript (r: NSRange) -> String {
    return (self as NSString).substringWithRange(r)
  }
  
  public var fullRange: NSRange {
    return NSMakeRange(0, length)
  }
  
  public var length: Int {
    return (self as NSString).length
  }
}

public class CustomExpression {
  private let regex: NSRegularExpression?
  private let mapFn: (NSTextCheckingResult) -> NSRange
  private var identifier: String = ""

  public init(regex: String, mapFn: ((NSTextCheckingResult) -> NSRange)? = nil, identifier: String = "", options: NSRegularExpressionOptions = []) {
    self.regex = try? NSRegularExpression(pattern: regex, options: options)
    if let mapFn = mapFn {
      self.mapFn = mapFn
    } else {
      self.mapFn = { return $0.range }
    }
  }

  public func identifier(identifier: String) -> CustomExpression {
    self.identifier = identifier
    return self
  }
}

public class ActiveLabel: UILabel {

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

  @IBInspectable public var customElementsEnabled: Bool = true {
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

  @IBInspectable public var customColor: UIColor? {
    didSet {
      updateTextStorage()
    }
  }

  @IBInspectable public var customSelectedColor: UIColor? {
    didSet {
      updateTextStorage()
    }
  }

  @IBInspectable public var mentionHighlightedColor: UIColor? {
    didSet {
      updateTextStorage()
    }
  }

  @IBInspectable public var hashtagHighlightedColor: UIColor? {
    didSet {
      updateTextStorage()
    }
  }

  @IBInspectable public var URLHighlightedColor: UIColor? {
    didSet {
      updateTextStorage()
    }
  }

  @IBInspectable public var customHighlightedColor: UIColor? {
    didSet {
      updateTextStorage()
    }
  }

  @IBInspectable public var lineSpacing: Float? {
    didSet {
      updateTextStorage()
    }
  }

  // MARK: - public methods


  public func handleElementTap(handler: (ActiveElement) -> Void) {
    elementTapHandler = handler
  }
  
  public func shouldIgnoreElement(handler: (ActiveElement) -> Bool) {
    ignoreHandler = handler
  }

  // MARK: - override UILabel properties
  override public var text: String! {
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

  override public var textAlignment: NSTextAlignment {
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

  public override func drawTextInRect(rect: CGRect) {
    let range = NSRange(location: 0, length: textStorage.length)

    textContainer.size = rect.size
    let newOrigin = textOrigin(inRect: rect)

    layoutManager.drawBackgroundForGlyphRange(range, atPoint: newOrigin)
    layoutManager.drawGlyphsForGlyphRange(range, atPoint: newOrigin)
  }

  public override func sizeThatFits(size: CGSize) -> CGSize {
    let currentSize = textContainer.size
    defer {
      textContainer.size = currentSize
    }

    textContainer.size = size
    return layoutManager.usedRectForTextContainer(textContainer).size
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

      if elementAtLocation(location) != nil {
        self.didTapElement(selectedElement.element)
      }

      let when = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
      dispatch_after(when, dispatch_get_main_queue()) {
        self.updateAttributesWhenSelected(false)
        self.selectedElement = nil
      }
      avoidSuperCall = true
    case .Cancelled:
      self.updateAttributesWhenSelected(false)
      self.selectedElement = nil
    default: ()
    }

    return avoidSuperCall
  }

  // MARK: - private properties
  private var elementTapHandler: ((ActiveElement) -> Void)?
  private var ignoreHandler: ((ActiveElement) -> Bool)? {
    didSet {
      updateTextStorage()
    }
  }
  private var selectedElement: (range: NSRange, element: ActiveElement)?
  private var heightCorrection: CGFloat = 0
  private lazy var textStorage = NSTextStorage()
  private lazy var layoutManager = NSLayoutManager()
  private lazy var textContainer = NSTextContainer()
  private lazy var activeElements: [ActiveType: [(range: NSRange, element: ActiveElement)]] = [
    .Mention: [],
    .Hashtag: [],
    .URL: [],
    .CustomExpression: []
    ]

  public var customExpressions: [CustomExpression] = [] {
    didSet {
      updateTextStorage()
    }
  }

  private static let expressions: [(type: ActiveType, regex: NSRegularExpression?, group: Int, preferredGroup: Int)] = [
    (.Mention, try? NSRegularExpression(pattern: "(\\W+|^)(@([a-zA-Z0-9\\_-]+))", options: []), 2, 3),
    (.Hashtag, try? NSRegularExpression(pattern: "(\\W+|^)(#([a-zA-Z0-9\\_-]+))", options: []), 2, 3),
    (.URL, try? NSDataDetector(types: NSTextCheckingType.Link.rawValue), 0, 0)
  ]

  // MARK: - helper functions
  private func setupLabel() {
    textStorage.addLayoutManager(layoutManager)
    layoutManager.addTextContainer(textContainer)
    textContainer.lineFragmentPadding = 0
    userInteractionEnabled = true
  }

  private func updateTextStorage() {
    guard let attributedText = attributedText where superview != nil else {
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
    attributes[NSBackgroundColorAttributeName] = UIColor.clearColor()

    for (type, elements) in activeElements {

      switch type {
      case .Mention:
        attributes[NSForegroundColorAttributeName] = mentionColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clearColor()
      case .Hashtag:
        attributes[NSForegroundColorAttributeName] = hashtagColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clearColor()
      case .URL:
        attributes[NSForegroundColorAttributeName] = URLColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clearColor()
      case .CustomExpression:
        attributes[NSForegroundColorAttributeName] = customColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clearColor()
      case .None: ()
      }
      elements.forEach { mutAttrString.setAttributes(attributes, range: $0.range) }
    }
  }

  public static func extractAttributesFromString(textString: String, customExpressions: [CustomExpression] = []) -> [ActiveType: [(range:NSRange, element:ActiveElement)]] {
    let searchRange = textString.fullRange
    var elementsDictionary: [ActiveType: [(range:NSRange, element:ActiveElement)]] = [
      .Mention: [],
      .URL: [],
      .Hashtag: [],
      .CustomExpression: []
    ]

    expressions
      .flatMap { expression -> (ActiveType, NSRegularExpression, Int, Int)? in
        guard let regex = expression.regex else { return nil }
        return (expression.type, regex, expression.group, expression.preferredGroup)
      }
      .forEach { expression in
        let elements = expression.1.matchesInString(textString, options: [], range: searchRange).flatMap { (result:NSTextCheckingResult) -> (NSRange, ActiveElement)? in
          let word: String = textString[result.rangeAtIndex(expression.3)].stringByReplacingOccurrencesOfString(" ", withString: "")
          let element = expression.0.createElement(word)
          return (result.rangeAtIndex(expression.2), element)
        }
        elements.forEach {
          elementsDictionary[expression.0]?.append(($0.0, $0.1))
        }
    }

    customExpressions
      .forEach { expression in
        expression.regex?.matchesInString(textString, options: [], range: searchRange)
          .forEach { result in
            let range = expression.mapFn(result)
            elementsDictionary[.CustomExpression]?.append((range, ActiveType.CustomExpression.createElement(textString[range], identifier: expression.identifier)))
          }
      }

    return elementsDictionary
  }

  /// use regex check all link ranges
  private func parseTextAndExtractActiveElements(attrString: NSAttributedString) {
    let elements = ActiveLabel.extractAttributesFromString(attrString.string, customExpressions: customExpressions)

    let mapElements = { (element: (range:NSRange, element:ActiveElement)) -> (range:NSRange, element:ActiveElement)? in
      if self.ignoreHandler == nil || self.ignoreHandler?(element.1) == false {
        return element
      } else {
        return nil
      }
    }

    elements.flatMap { (value:(ActiveType, [(range: NSRange, element: ActiveElement)])) -> (ActiveType, [(range: NSRange, element: ActiveElement)])? in
      switch value.0 {
        case .Hashtag where self.hashtagEnabled,
              .Mention where self.mentionEnabled,
              .URL where self.URLEnabled,
              .CustomExpression where self.customElementsEnabled:
        return (value.0, value.1.flatMap(mapElements))
      default: return nil
      }
      }.forEach { (value:(ActiveType, [(range: NSRange, element: ActiveElement)])) in
        self.activeElements[value.0] = value.1
    }
  }

  /// add line break mode
  private func addLineBreak(attrString: NSAttributedString) -> NSMutableAttributedString {
    let mutAttrString = NSMutableAttributedString(attributedString: attrString)

    var range = NSRange(location: 0, length: 0)
    var attributes = mutAttrString.attributesAtIndex(0, effectiveRange: &range)

    let paragraphStyle = attributes[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
    paragraphStyle.alignment = textAlignment
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
      case .Mention(_):
        attributes[NSForegroundColorAttributeName] = mentionColor
        attributes[NSBackgroundColorAttributeName] = mentionHighlightedColor
      case .Hashtag(_):
        attributes[NSForegroundColorAttributeName] = hashtagColor
        attributes[NSBackgroundColorAttributeName] = hashtagHighlightedColor
      case .URL(_):
        attributes[NSForegroundColorAttributeName] = URLColor
        attributes[NSBackgroundColorAttributeName] = URLHighlightedColor
      case .CustomExpression(_, _):
        attributes[NSForegroundColorAttributeName] = customColor
        attributes[NSBackgroundColorAttributeName] = customHighlightedColor
      case .None: ()
      }
    } else {
      switch selectedElement.element {
      case .Mention(_):
        attributes[NSForegroundColorAttributeName] = mentionSelectedColor ?? mentionColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clearColor()
      case .Hashtag(_):
        attributes[NSForegroundColorAttributeName] = hashtagSelectedColor ?? hashtagColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clearColor()
      case .URL(_):
        attributes[NSForegroundColorAttributeName] = URLSelectedColor ?? URLColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clearColor()
      case .CustomExpression(_, _):
        attributes[NSForegroundColorAttributeName] = customSelectedColor ?? customColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clearColor()
      case .None: ()
      }
    }

    textStorage.addAttributes(attributes, range: selectedElement.range)

    setNeedsDisplay()
  }

  public func elementAtLocation(location: CGPoint) -> (range: NSRange, element: ActiveElement)? {
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

  public override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    onTouch(touch)
    super.touchesCancelled(touches, withEvent: event)
  }

  public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    if onTouch(touch) { return }
    super.touchesEnded(touches, withEvent: event)
  }

  //MARK: - ActiveLabel handler

  private func didTapElement(element: ActiveElement) {
    elementTapHandler?(element)
  }

  public override func didMoveToSuperview() {
    super.didMoveToSuperview()
    updateTextStorage()
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
