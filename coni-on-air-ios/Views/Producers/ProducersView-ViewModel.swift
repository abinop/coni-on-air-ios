//
//  ProducersView-ViewModel.swift
//  coni-on-air
//

import Foundation
import FirebaseDatabase

extension ProducersView {
    @MainActor class ViewModel: ObservableObject {
        @Published var producers: [Producer] = []
        @Published var selectedProducer: Producer?
        
        private lazy var dbPath: DatabaseReference? = {
            let ref = Database.database()
                .reference()
                .child("producers")
            return ref
        }()

        private let decoder = JSONDecoder()

        init() {
            listenForProducers()
        }

        func listenForProducers() {
            guard let dbPath = dbPath else {
                return
            }

            dbPath.observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self, let json = snapshot.value as? [String: Any] else {
                    return
                }
                var prods: [Producer] = []
                json.forEach({
                    if var producerJson = $0.value as? [String: Any] {
                        producerJson["id"] = $0.key
                        do {
                            let producerData = try JSONSerialization.data(withJSONObject: producerJson)
                            var producer = try self.decoder.decode(Producer.self, from: producerData)
                            producer.populateDescription()
                            prods.append(producer)
                        } catch {
                            print("an error occurred", error)
                        }
                    }
                })
                self.producers = prods.sorted(by: {$0.name < $1.name})
            }
        }
    }
}
