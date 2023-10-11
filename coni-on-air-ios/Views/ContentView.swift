//
//  ContentView.swift
//  coni-on-air-ios
//

import SwiftUI

struct OrientationLockedView<Content: View>: UIViewControllerRepresentable {
    var orientation: UIInterfaceOrientationMask
    var content: () -> Content
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<OrientationLockedView<Content>>) -> UIHostingController<Content> {
        return OrientationLockedHostingController(rootView: content(), orientation: orientation)
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<OrientationLockedView<Content>>) {
        // Nothing
    }
}

class OrientationLockedHostingController<Content: View>: UIHostingController<Content> {
    var orientation: UIInterfaceOrientationMask
    
    init(rootView: Content, orientation: UIInterfaceOrientationMask) {
        self.orientation = orientation
        super.init(rootView: rootView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return orientation
    }
}


struct ContentView: View {
    @StateObject var tabData = TabViewModel()
    @Namespace var animation

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        TabView(selection: $tabData.currentTab) {
            OrientationLockedView(orientation: .portrait) {
                RadioView()
            }
            .tag("Radio")

            OrientationLockedView(orientation: .portrait) {
                ProducersView().environmentObject(tabData)
            }
            .tag("Producers")

            OrientationLockedView(orientation: .portrait) {
                ChatView()
            }
            .tag("Chat")

            OrientationLockedView(orientation: .landscape) {
                LiveView()
            }
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
