//
//  ActiveLabelHandler.swift
//  ActiveLabel
//
//  Created by Viktor Kalinchuk on 2/22/19.
//  Copyright © 2019 Optonaut. All rights reserved.
//

import Foundation

typealias HandlerResult = (handled: Bool, selectedText: String)

class ActiveLabelHandler {

    var mentionTapHandler: ((String) -> ())?
    var hashtagTapHandler: ((String) -> ())?
    var urlTapHandler: ((URL) -> ())?
    var customTapHandlers: [ActiveType : ((String) -> ())] = [:]

    func handle(selectedElement: ElementTuple) -> HandlerResult {
        switch selectedElement.element {
        case .mention(let userHandle):
            return handle(mention: userHandle)
        case .hashtag(let hashtag):
            return handle(hashtag: hashtag)
        case .url(let originalURL, _):
            return handle(stringURL: originalURL)
        case .custom(let element):
            return handle(element: element, for: selectedElement.type)
        }
    }

    func removeHandler(for type: ActiveType) {
        switch type {
        case .hashtag:
            hashtagTapHandler = nil
        case .mention:
            mentionTapHandler = nil
        case .url:
            urlTapHandler = nil
        case .custom:
            customTapHandlers[type] = nil
        }
    }

    func removeAllHandlers() {
        hashtagTapHandler = nil
        mentionTapHandler = nil
        urlTapHandler = nil
        customTapHandlers.removeAll()
    }

    // MARK: - Private methods

    private func handle(mention username: String) -> HandlerResult {
        guard let mentionHandler = mentionTapHandler else {
            return (handled: false, selectedText: username)
        }

        mentionHandler(username)
        return (handled: true, selectedText: username)
    }

    private func handle(hashtag: String) -> HandlerResult {
        guard let hashtagHandler = hashtagTapHandler else {
            return (handled: false, selectedText: hashtag)
        }

        hashtagHandler(hashtag)
        return (handled: true, selectedText: hashtag)
    }

    private func handle(stringURL: String) -> HandlerResult {
        let escaped = stringURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let urlHandler = urlTapHandler, let url = escaped.flatMap(URL.init(string:)) else {
            return (handled: false, selectedText: stringURL)
        }

        urlHandler(url)
        return (handled: true, selectedText: stringURL)
    }

    private func handle(element: String, for type: ActiveType) -> HandlerResult {
        guard let elementHandler = customTapHandlers[type] else {
            return (handled: false, selectedText: element)
        }

        elementHandler(element)
        return (handled: true, selectedText: element)
    }

}
