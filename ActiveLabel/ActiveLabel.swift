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
    return (self as NSString).substring(with: r)
  }
  
  public var fullRange: NSRange {
    return NSMakeRange(0, length)
  }
  
  public var length: Int {
    return (self as NSString).length
  }
}

public class CustomExpression {
  fileprivate let regex: NSRegularExpression?
  fileprivate let mapFn: (NSTextCheckingResult) -> NSRange
  fileprivate var identifier: String = ""

  public init(regex: String, mapFn: ((NSTextCheckingResult) -> NSRange)? = nil, identifier: String = "", options: NSRegularExpression.Options = []) {
    self.regex = try? NSRegularExpression(pattern: regex, options: options)
    if let mapFn = mapFn {
      self.mapFn = mapFn
    } else {
      self.mapFn = { return $0.range }
    }
  }

  public func identifier(_ identifier: String) -> CustomExpression {
    self.identifier = identifier
    return self
  }
}

open class ActiveLabel: UILabel {

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

  @IBInspectable public var mentionColor: UIColor = .blue {
    didSet {
      updateTextStorage()
    }
  }

  @IBInspectable public var mentionSelectedColor: UIColor? {
    didSet {
      updateTextStorage()
    }
  }

  @IBInspectable public var hashtagColor: UIColor = .blue {
    didSet {
      updateTextStorage()
    }
  }

  @IBInspectable public var hashtagSelectedColor: UIColor? {
    didSet {
      updateTextStorage()
    }
  }

  @IBInspectable public var URLColor: UIColor = .blue {
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


  public func handleElementTap(_ handler: @escaping (ActiveElement) -> Void) {
    elementTapHandler = handler
  }
  
  public func shouldIgnoreElement(_ handler: @escaping (ActiveElement) -> Bool) {
    ignoreHandler = handler
  }

  // MARK: - override UILabel properties
  override open var text: String! {
    didSet {
      updateTextStorage()
    }
  }

  override open var attributedText: NSAttributedString? {
    didSet {
      updateTextStorage()
    }
  }

  override open var font: UIFont! {
    didSet {
      updateTextStorage()
    }
  }

  override open var textColor: UIColor! {
    didSet {
      updateTextStorage()
    }
  }

  override open var textAlignment: NSTextAlignment {
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

  open override func drawText(in rect: CGRect) {
    let range = NSRange(location: 0, length: textStorage.length)

    textContainer.size = rect.size
    let newOrigin = textOrigin(inRect: rect)

    layoutManager.drawBackground(forGlyphRange: range, at: newOrigin)
    layoutManager.drawGlyphs(forGlyphRange: range, at: newOrigin)
  }

  open override func sizeThatFits(_ size: CGSize) -> CGSize {
    let currentSize = textContainer.size
    defer {
      textContainer.size = currentSize
    }

    textContainer.size = size
    return layoutManager.usedRect(for: textContainer).size
  }

  // MARK: - touch events
  func onTouch(_ touch: UITouch) -> Bool {
    let location = touch.location(in: self)
    var avoidSuperCall = false

    switch touch.phase {
    case .began, .moved:
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
    case .ended:
      guard let selectedElement = selectedElement else { return avoidSuperCall }

      if elementAtLocation(location) != nil {
        self.didTapElement(selectedElement.element)
      }

      let when = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
      DispatchQueue.main.asyncAfter(deadline: when) {
        self.updateAttributesWhenSelected(false)
        self.selectedElement = nil
      }
      avoidSuperCall = true
    case .cancelled:
      self.updateAttributesWhenSelected(false)
      self.selectedElement = nil
    default: ()
    }

    return avoidSuperCall
  }

  // MARK: - private properties
  fileprivate var elementTapHandler: ((ActiveElement) -> Void)?
  fileprivate var ignoreHandler: ((ActiveElement) -> Bool)? {
    didSet {
      updateTextStorage()
    }
  }
  fileprivate var selectedElement: (range: NSRange, element: ActiveElement)?
  fileprivate var heightCorrection: CGFloat = 0
  fileprivate lazy var textStorage = NSTextStorage()
  fileprivate lazy var layoutManager = NSLayoutManager()
  fileprivate lazy var textContainer = NSTextContainer()
  fileprivate lazy var activeElements: [ActiveType: [(range: NSRange, element: ActiveElement)]] = [
    .mention: [],
    .hashtag: [],
    .url: [],
    .customExpression: []
    ]

  open var customExpressions: [CustomExpression] = [] {
    didSet {
      updateTextStorage()
    }
  }

  fileprivate static let expressions: [(type: ActiveType, regex: NSRegularExpression?, group: Int, preferredGroup: Int)] = [
    (.mention, try? NSRegularExpression(pattern: "(\\W+|^)(@([a-zA-Z0-9\\_-]+))", options: []), 2, 3),
    (.hashtag, try? NSRegularExpression(pattern: "(\\W+|^)(#([a-zA-Z0-9\\_-]+))", options: []), 2, 3),
    (.url, try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue), 0, 0)
  ]

  // MARK: - helper functions
  fileprivate func setupLabel() {
    textStorage.addLayoutManager(layoutManager)
    layoutManager.addTextContainer(textContainer)
    textContainer.lineFragmentPadding = 0
    isUserInteractionEnabled = true
  }

  fileprivate func updateTextStorage() {
    guard let attributedText = attributedText , superview != nil else {
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

  fileprivate func textOrigin(inRect rect: CGRect) -> CGPoint {
    let usedRect = layoutManager.usedRect(for: textContainer)
    heightCorrection = (rect.height - usedRect.height)/2
    let glyphOriginY = heightCorrection > 0 ? rect.origin.y + heightCorrection : rect.origin.y
    return CGPoint(x: rect.origin.x, y: glyphOriginY)
  }

  /// add link attribute
  fileprivate func addLinkAttribute(_ mutAttrString: NSMutableAttributedString) {
    var range = NSRange(location: 0, length: 0)
    var attributes = mutAttrString.attributes(at: 0, effectiveRange: &range)

    attributes[NSFontAttributeName] = font!
    attributes[NSForegroundColorAttributeName] = textColor

    mutAttrString.addAttributes(attributes, range: range)

    attributes[NSForegroundColorAttributeName] = mentionColor
    attributes[NSBackgroundColorAttributeName] = UIColor.clear

    for (type, elements) in activeElements {

      switch type {
      case .mention:
        attributes[NSForegroundColorAttributeName] = mentionColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clear
      case .hashtag:
        attributes[NSForegroundColorAttributeName] = hashtagColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clear
      case .url:
        attributes[NSForegroundColorAttributeName] = URLColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clear
      case .customExpression:
        attributes[NSForegroundColorAttributeName] = customColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clear
      case .none: ()
      }
      elements.forEach { mutAttrString.setAttributes(attributes, range: $0.range) }
    }
  }

  open static func extractAttributesFromString(_ textString: String, customExpressions: [CustomExpression] = []) -> [ActiveType: [(range:NSRange, element:ActiveElement)]] {
    let searchRange = textString.fullRange
    var elementsDictionary: [ActiveType: [(range:NSRange, element:ActiveElement)]] = [
      .mention: [],
      .url: [],
      .hashtag: [],
      .customExpression: []
    ]

    expressions
      .flatMap { expression -> (ActiveType, NSRegularExpression, Int, Int)? in
        guard let regex = expression.regex else { return nil }
        return (expression.type, regex, expression.group, expression.preferredGroup)
      }
      .forEach { expression in
        let elements = expression.1.matches(in: textString, options: [], range: searchRange).flatMap { (result:NSTextCheckingResult) -> (NSRange, ActiveElement)? in
          let word: String = textString[result.rangeAt(expression.3)].replacingOccurrences(of: " ", with: "")
          let element = expression.0.createElement(word)
          return (result.rangeAt(expression.2), element)
        }
        elements.forEach {
          elementsDictionary[expression.0]?.append(($0.0, $0.1))
        }
    }

    customExpressions
      .forEach { expression in
        expression.regex?.matches(in: textString, options: [], range: searchRange)
          .forEach { result in
            let range = expression.mapFn(result)
            elementsDictionary[.customExpression]?.append((range, ActiveType.customExpression.createElement(textString[range], identifier: expression.identifier)))
          }
      }

    return elementsDictionary
  }

  /// use regex check all link ranges
  fileprivate func parseTextAndExtractActiveElements(_ attrString: NSAttributedString) {
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
        case .hashtag where self.hashtagEnabled,
              .mention where self.mentionEnabled,
              .url where self.URLEnabled,
              .customExpression where self.customElementsEnabled:
        return (value.0, value.1.flatMap(mapElements))
      default: return nil
      }
      }.forEach { (value:(ActiveType, [(range: NSRange, element: ActiveElement)])) in
        self.activeElements[value.0] = value.1
    }
  }

  /// add line break mode
  fileprivate func addLineBreak(_ attrString: NSAttributedString) -> NSMutableAttributedString {
    let mutAttrString = NSMutableAttributedString(attributedString: attrString)

    var range = NSRange(location: 0, length: 0)
    var attributes = mutAttrString.attributes(at: 0, effectiveRange: &range)

    let paragraphStyle = attributes[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
    paragraphStyle.alignment = textAlignment
    if let lineSpacing = lineSpacing {
      paragraphStyle.lineSpacing = CGFloat(lineSpacing)
    }

    attributes[NSParagraphStyleAttributeName] = paragraphStyle
    mutAttrString.setAttributes(attributes, range: range)

    return mutAttrString
  }

  fileprivate func updateAttributesWhenSelected(_ isSelected: Bool) {
    guard let selectedElement = selectedElement else {
      return
    }

    var attributes = textStorage.attributes(at: 0, effectiveRange: nil)
    if isSelected {
      switch selectedElement.element {
      case .mention(_):
        attributes[NSForegroundColorAttributeName] = mentionColor
        attributes[NSBackgroundColorAttributeName] = mentionHighlightedColor
      case .hashtag(_):
        attributes[NSForegroundColorAttributeName] = hashtagColor
        attributes[NSBackgroundColorAttributeName] = hashtagHighlightedColor
      case .url(_):
        attributes[NSForegroundColorAttributeName] = URLColor
        attributes[NSBackgroundColorAttributeName] = URLHighlightedColor
      case .customExpression(_, _):
        attributes[NSForegroundColorAttributeName] = customColor
        attributes[NSBackgroundColorAttributeName] = customHighlightedColor
      case .none: ()
      }
    } else {
      switch selectedElement.element {
      case .mention(_):
        attributes[NSForegroundColorAttributeName] = mentionSelectedColor ?? mentionColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clear
      case .hashtag(_):
        attributes[NSForegroundColorAttributeName] = hashtagSelectedColor ?? hashtagColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clear
      case .url(_):
        attributes[NSForegroundColorAttributeName] = URLSelectedColor ?? URLColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clear
      case .customExpression(_, _):
        attributes[NSForegroundColorAttributeName] = customSelectedColor ?? customColor
        attributes[NSBackgroundColorAttributeName] = UIColor.clear
      case .none: ()
      }
    }

    textStorage.addAttributes(attributes, range: selectedElement.range)

    setNeedsDisplay()
  }

  open func elementAtLocation(_ location: CGPoint) -> (range: NSRange, element: ActiveElement)? {
    guard textStorage.length > 0 else {
      return nil
    }

    var correctLocation = location
    correctLocation.y -= heightCorrection
    let boundingRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: 0, length: textStorage.length), in: textContainer)
    guard boundingRect.contains(correctLocation) else {
      return nil
    }

    let index = layoutManager.glyphIndex(for: correctLocation, in: textContainer)

    for element in activeElements.map({ $0.1 }).joined() {
      if index >= element.range.location && index <= element.range.location + element.range.length {
        return element
      }
    }

    return nil
  }


  //MARK: - Handle UI Responder touches
  open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    if onTouch(touch) { return }
    super.touchesBegan(touches, with: event)
  }

  open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    if onTouch(touch) { return }
    super.touchesCancelled(touches, with: event)
  }

  open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    if onTouch(touch) { return }
    super.touchesEnded(touches, with: event)
  }

  //MARK: - ActiveLabel handler

  fileprivate func didTapElement(_ element: ActiveElement) {
    elementTapHandler?(element)
  }

  open override func didMoveToSuperview() {
    super.didMoveToSuperview()
    updateTextStorage()
  }
}

extension ActiveLabel: UIGestureRecognizerDelegate {

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
