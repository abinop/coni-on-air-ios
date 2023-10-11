//
//  MessageRow.swift
//  coni-on-air
//

import SwiftUI

struct MessageRow: View {
    @State var message: Message
    var body: some View {
        VStack(alignment: .leading) {
            Text(message.who ?? "_who_")
                .foregroundColor(.white)
                .font(.caption)
                .bold()
            Text(message.when ?? "_when_")
                .foregroundColor(.white)
                .font(.caption2)
                .italic()
            Text(message.message)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color("color-blue"))
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
        }
    }
}
