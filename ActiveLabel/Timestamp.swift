//
//  Timestamp.swift
//  ActiveLabel
//
//  Created by Steve Kim on 2022/03/31.
//  Copyright © 2022 Optonaut. All rights reserved.
//

import Foundation

// MARK: - Timestamp

public enum Timestamp {
    case `default`(_ timeString: String)
    case chapter(_ timeString: String, title: String? = nil)
}

extension Timestamp {

    // MARK: Public

    public static func create(_ timeString: String, range: NSRange, in text: String) -> Self {
        switch prevCharacter(of: range, in: text) {
        case "\n", "":
            let location = range.location + range.length + 1
            return .chapter(timeString, title: chapterTitle(at: location, in: text))
        default:
            return .default(timeString)
        }
    }

    // MARK: Internal

    static func filter(at range: NSRange, with text: String?) -> Bool {
        guard let prev = prevCharacter(of: range, in: text) else { return true }
        return Int(prev) == nil
    }

    // MARK: Private

    private static func chapterTitle(at location: Int, in text: String?) -> String? {
        guard let text = text else { return nil }
        let tailRange = NSMakeRange(location, max(0, text.count - location))
        return text[at: tailRange]
            .flatMap {
                (text: $0, range: NSMakeRange(0, $0.count))
            }
            .flatMap {
                if RegexParser.isMatchToAnyPatterns(from: $0.text, range: $0.range) {
                    return nil
                }
                let matched = RegexParser.getElements(from: $0.text, with: RegexParser.timestampChapterTitlePattern, range: $0.range).first
                return $0.text[at: matched?.range]?.replacingOccurrences(of: "\n", with: "")
            }
    }

    private static func prevCharacter(of range: NSRange, in text: String?) -> String? {
        guard let text = text else { return nil }
        let prevCharacterRange = NSMakeRange(range.location - 1, 1)
        return text[at: prevCharacterRange]
    }
}

extension Timestamp {

    // MARK: Public

    public var timeInterval: TimeInterval {
        switch self {
        case .`default`(let timeString),
             .chapter(let timeString, _):
            return timeInterval(from: timeString)
        }
    }
    public var presentableText: String {
        switch self {
        case .`default`(_):
            return timeString(from: timeInterval)
        case .chapter(_, let title):
            return title ?? timeString(from: timeInterval)
        }
    }
    public var timeString: String {
        switch self {
        case .`default`(let timeString),
             .chapter(let timeString, _):
            return timeString
        }
    }

    // MARK: Private

    private func timeInterval(from string: String) -> TimeInterval {
        let tokens = string.components(separatedBy: ":")

        guard 2 ... 3 ~= tokens.count else { return 0 }

        let hours: Int
        let minutes: Int
        let seconds: Int
        if tokens.count == 2 {
            hours = 0
            minutes = Int(tokens[0]) ?? 0
            seconds = Int(tokens[1]) ?? 0
        } else {
            hours = Int(tokens[0]) ?? 0
            minutes = Int(tokens[1]) ?? 0
            seconds = Int(tokens[2]) ?? 0
        }
        let totalSeconds = hours * Int(3600) + minutes * Int(60) + seconds
        return TimeInterval(totalSeconds)
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let casted = Int(timeInterval)
        let seconds = casted % 60
        let minutes = (casted / 60) % 60
        let hours = (casted / 3600)
        return hours > 0 ?
            .init(format: "%d:%02d:%02d", hours, minutes, seconds) :
            .init(format: "%02d:%02d", minutes, seconds)
    }
}
