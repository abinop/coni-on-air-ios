//
//  ContentView.swift
//  coni-on-air-ios
//

import SwiftUI

struct ContentView: View {
    @StateObject var tabData = TabViewModel()
    @Namespace var animation

    init() {
//        print("📱 [ContentView] Initializing ContentView")
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        TabView(selection: $tabData.currentTab) {
            RadioView()
                .tag("Radio")
            ProducersView()
                .environmentObject(tabData)
                .tag("Producers")
            ChatView()
                .tag("Chat")
            LiveView()
                .tag("Live")
        }
        .overlay(alignment: .bottom) {
            if tabData.isVisible {
                HStack {
                    TabBarButton(id: "Radio", title: "RADIO", image: "radio", animation: animation)
                    TabBarButton(id: "Producers", title: "PRODUCERS", image: "person.3.fill", animation: animation)
                    TabBarButton(id: "Chat", title: "CHAT", image: "text.bubble.fill", animation: animation)
                    TabBarButton(id: "Live", title: "LIVE", image: "video.fill", animation: animation)
                }
                .environmentObject(tabData)
                .padding(.vertical, 14)
                .padding(.horizontal)
                .background(Color(uiColor: .darkGray), in: Capsule())
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
//                .onAppear { print("📱 [ContentView] Tab bar overlay appeared") }
            }
        }
        .ignoresSafeArea(.keyboard)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue)
        .onAppear { 
//            print("📱 [ContentView] Entire view appeared")
//            print("📱 [ContentView] Current tab: \(tabData.currentTab), isVisible: \(tabData.isVisible)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
