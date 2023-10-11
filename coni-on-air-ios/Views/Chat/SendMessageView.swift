//
//  SendMessageView.swift
//  coni-on-air
//

import SwiftUI

struct SendMessageView: View {

    enum FocusedField {
        case name, message
    }

    @Binding var name: String
    @Binding var message: String
    @FocusState private var focusedField: FocusedField?

    var onCancel: (()->())
    var onSend: (()->())

    var body: some View {
        VStack(spacing: 16) {
            Color.clear
                .frame(height: 0)
                Text("NEW_MESSAGE")
                    .foregroundColor(.white)
                    .font(.title3)
            VStack {
                ZStack(alignment: .topLeading) {
                    if name.isEmpty {
                        Text("CHAT_NAME_PLACEHOLDER")
                            .foregroundColor(Color.white.opacity(0.65))
                    }
                    TextField("", text: $name)
                        .foregroundColor(.white)
                        .background(Color.clear)
                        .textFieldStyle(.plain)
                        .focused($focusedField, equals: .name)
                }
                Divider()
                        .overlay(Color.white)
            }
            .padding(.horizontal)
            VStack {
                ZStack(alignment: .topLeading) {
                    if message.isEmpty {
                        Text("CHAT_MESSAGE_PLACEHOLDER")
                            .foregroundColor(Color.white.opacity(0.65))
                    }
                    TextField("", text: $message, axis: .vertical)
                        .foregroundColor(.white)
                        .background(Color.clear)
                        .lineLimit(5, reservesSpace: false)
                        .textFieldStyle(.plain)
                        .focused($focusedField, equals: .message)
                }
                Divider()
                    .overlay(Color.white)
            }
            .padding(.horizontal)
            HStack {
                Button {
                    onCancel()
                } label: {
                    HStack {
                        Image(systemName: "x.circle.fill")
                        Text("CANCEL")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.pink)
                Button {
                    guard message.count > 3 && name.count > 3 else {
                        return
                    }
                    onSend()
                } label: {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("SEND")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("color-blue"))
                .opacity((message.count < 3 || name.count < 3) ? 0.5 : 1)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color("color-black").edgesIgnoringSafeArea(.all))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .white.opacity(0.1), radius: 3)
        .onAppear {
            if name.isEmpty {
                focusedField = .name
            } else {
                focusedField = .message
            }
        }
    }
}


struct SendMessageView_Previews: PreviewProvider {
    static var previews: some View {
        SendMessageView(name: .constant(""), message: .constant("")) {

        } onSend: {

        }

    }
}
