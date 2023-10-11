//
//  Message.swift
//  coni-on-air
//

import Foundation

struct Message: Identifiable, Hashable, Codable {
    let id: String
    let message: String
    let who: String?
    let timewhen: Double

    var when: String? {
        let date = Date(timeIntervalSince1970: timewhen/1000)
        return DateFormatter.mediumDateTimeFormatter.string(from: date)
    }

    enum CodingKeys: String, CodingKey {
        case id, message, who, timewhen, userId
    }

    init(message: String, who: String) {
        self.id = UUID().uuidString
        self.message = message
        self.who = who
        self.timewhen = Date().timeIntervalSince1970
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
        try container.encodeIfPresent(who, forKey: .who)
        try container.encode(timewhen*1000, forKey: .timewhen)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        let tmpMessage = try values.decode(String.self, forKey: .message)
        let removedUsernameData = Message.removeUsername(in: tmpMessage)
        if let actualMessage = removedUsernameData?.modifiedText, let actualName = removedUsernameData?.username {
            message = actualMessage
            who = actualName
        } else {
            message = tmpMessage
            who = try values.decodeIfPresent(String.self, forKey: .who)
        }
        timewhen = try values.decode(Double.self, forKey: .timewhen)        
    }

    static func removeUsername(in text: String) -> (modifiedText: String, username: String)? {
        let pattern = "<i>(.*?)</i> : "
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: text.utf16.count)

        if let result = regex?.firstMatch(in: text, options: [], range: range) {
            let usernameRange = result.range(at: 1)
            let username = (text as NSString).substring(with: usernameRange)
            let replacedText = regex?.stringByReplacingMatches(in: text, options: [], range: result.range, withTemplate: "")

            return (replacedText ?? text, username)
        } else {
            return nil
        }
    }
}
