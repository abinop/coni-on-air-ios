//
//  Producer.swift
//  coni-on-air
//

import Foundation

struct Producer: Identifiable, Hashable, Codable {
    var id: String
    var name: String
    var descrEn: String
    var descrGr: String
    var photo: String
    var show: String

    var attributedDesc: NSAttributedString?

    mutating func populateDescription() {
        if Locale.current.language.languageCode?.identifier == "el" {
            attributedDesc = descrGr.htmlToAttributedString().attributedStringByTrimmingCharacterSet(charSet: .whitespacesAndNewlines)
        } else {
            attributedDesc = descrEn.htmlToAttributedString().attributedStringByTrimmingCharacterSet(charSet: .whitespacesAndNewlines)
        }
    }

    enum CodingKeys: String, CodingKey {
        case descrEn = "descr_en"
        case descrGr = "descr_gr"
        case id, name, photo, show
    }
}

