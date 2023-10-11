//
//  AttributedText.swift
//  coni-on-air
//

import Foundation
import SwiftUI

struct AttributedText: UIViewRepresentable {
    let attributedString: NSAttributedString?

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = attributedString
        uiView.tintColor = .white
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        DispatchQueue.main.async {
            uiView.preferredMaxLayoutWidth = uiView.bounds.width
            uiView.sizeToFit()
        }
    }
}

extension String {
    func htmlToAttributedString(extraAttributes: [NSAttributedString.Key:Any]? = nil) -> NSAttributedString {
        var stringToUse: String {
            let wholeString = """
            <!doctype html>
            <head>
                <meta charset="utf-8">
                <style type="text/css">
                    /*
                      Custom CSS styling of HTML formatted text.
                      Note, only a limited number of CSS features are supported by NSAttributedString/UITextView.
                    */

                    body {
                        font: -apple-system-body;
                        color: \(UIColor.white.toHexString());
                    }

                    h1, h2, h3, h4, h5, h6 {
                        color: \(UIColor.white.toHexString());
                    }

                    a {
                        color: \(UIColor.white.toHexString());
                        text-decoration: none;
                    }

                    li:last-child {
                        margin-bottom: 1em;
                    }
                </style>
            </head>
            <body>
                \(self)
            </body>
            </html>
            """
            return wholeString.replacingOccurrences(of: "\r\n", with: "<br>")
        }
        guard let data = stringToUse.data(using: .utf8) else { return NSAttributedString(string: self) }
        do{
            let str = try NSMutableAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            str.enumerateAttributes(in: NSRange(0..<str.length), options: []) { (attributes, range, _) -> Void in
                for (attribute, _) in attributes {
                    if attribute == .link {
                        str.removeAttribute(.link, range: range)
                    }
                }
            }
            return str
        }catch{
            return NSAttributedString(string: self)
        }
    }
}


extension UIColor {
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

extension NSAttributedString {
     public func attributedStringByTrimmingCharacterSet(charSet: CharacterSet) -> NSAttributedString {
         let modifiedString = NSMutableAttributedString(attributedString: self)
        modifiedString.trimCharactersInSet(charSet: charSet)
         return NSAttributedString(attributedString: modifiedString)
     }
}

extension NSMutableAttributedString {
     public func trimCharactersInSet(charSet: CharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: charSet as CharacterSet)

         // Trim leading characters from character set.
         while range.length != 0 && range.location == 0 {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet)
         }

         // Trim trailing characters from character set.
        range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
         while range.length != 0 && NSMaxRange(range) == length {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
         }
     }
}
