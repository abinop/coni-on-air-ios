//
//  ContentView.swift
//  coni-on-air-ios
//

import SwiftUI

struct ContentView: View {
    @StateObject var tabData = TabViewModel()
    @Namespace var animation

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        TabView(selection: $tabData.currentTab) {
            RadioView()
                .tag("Live")
            ProducersView()
                .environmentObject(tabData)
                .tag("Producers")
            ChatView()
                .tag("Chat")
        }
        .overlay(alignment: .bottom) {
            if tabData.isVisible {
                HStack {
                    TabBarButton(id: "Radio", title: "RADIO", image: "radio", animation: animation)
                    TabBarButton(id: "Producers", title: "PRODUCERS", image: "person.3.fill", animation: animation)
                    TabBarButton(id: "Chat", title: "CHAT", image: "text.bubble.fill", animation: animation)
                }
                .environmentObject(tabData)
                .padding(.vertical, 14)
                .padding(.horizontal)
                .background(Color(uiColor: .darkGray), in: Capsule())
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
