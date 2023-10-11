//
//  coni_on_air_iosApp.swift
//  coni-on-air-ios
//

import SwiftUI
import Firebase

@main
struct coni_on_air_iosApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
