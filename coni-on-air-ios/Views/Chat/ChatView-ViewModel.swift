//
//  ChatView-ViewModel.swift
//  coni-on-air
//

import Foundation
import Firebase

extension ChatView {
    @MainActor class ViewModel: ObservableObject {
        @Published var messages: [Message] = []
        @Published var isNewMessageVisible: Bool = false
        @Published var name: String = ""
        @Published var newMessage: String = ""
        @Published var shouldShowNewMessageError: Bool = false
        
        private lazy var dbPath: DatabaseReference? = {
            let ref = Database.database()
                .reference()
                .child("chat")
            return ref
        }()

        private let encoder = JSONEncoder()
        private let decoder = JSONDecoder()

        init() {
            self.name = UserDefaults.standard.string(forKey: "CHAT_USER_NAME") ?? ""
            listenForMessages()
        }

        func listenForMessages() {
            guard let dbPath = dbPath else {
                return
            }
            dbPath.queryLimited(toLast: 30).observe(.childAdded) { [weak self] snapshot in
                guard let self, var json = snapshot.value as? [String: Any] else {
                    return
                }
                json["id"] = snapshot.key
                do {
                    let messageData = try JSONSerialization.data(withJSONObject: json)
                    let message = try self.decoder.decode(Message.self, from: messageData)
                    // Insert the message at the beginning of the array
                    self.messages.insert(message, at: 0)
                } catch {
                    print("an error occurred", error)
                }
            } withCancel: { error in
                print(error.localizedDescription)
            }
        }

        func sendMessage() {
            guard let dbPath = dbPath else {
                return
            }
            guard name.count > 3, newMessage.count > 3 else { return }
            UserDefaults.standard.setValue(name, forKey: "CHAT_USER_NAME")
            UserDefaults.standard.synchronize()
            let message = Message(message: newMessage, who: name)
            do {
                let data = try encoder.encode(message)
                let json = try JSONSerialization.jsonObject(with: data)
                isNewMessageVisible = false
                dbPath
                    .childByAutoId()
                    .setValue(json) {[weak self] (error, snapshot) in
                        if error != nil {
                            self?.shouldShowNewMessageError = true
                        } else {
                            self?.newMessage = ""
                        }
                    }
            } catch {
                print(error)
            }
        }
    }
}
