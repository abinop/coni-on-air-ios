//
//  TabBarButton.swift
//  coni-on-air-ios
//

import SwiftUI

class TabViewModel: ObservableObject {
    @Published var currentTab = "Radio"
    @Published var isVisible: Bool = true
}

struct TabBarButton: View {
    var id: String
    var title: LocalizedStringKey
    var image: String
    var animation: Namespace.ID
    @EnvironmentObject var tabData: TabViewModel

    var body: some View {
        Button {
            withAnimation {
                tabData.currentTab = id
            }
        } label: {
            ZStack {
                VStack {
                    Image(systemName: image)
                        .font(.title2)
                        .frame(height: 18)
                    Text(title)
                        .font(.caption.bold())
                }
                .foregroundColor(tabData.currentTab == id ? Color.white : .gray)
                .frame(maxWidth: .infinity)
                .if(tabData.currentTab == id) { view in
                    view.background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .matchedGeometryEffect(id: "TAB", in: animation)
                            .padding(.vertical, -8)
                    )
                }
            }
        }
    }

    struct TabIndicator: Shape {
        func path(in rect: CGRect) -> Path {
            return Path { path in
                path.move(to: CGPoint(x: 10, y: 0))
                path.addLine(to: CGPoint(x: rect.width - 10, y: 0))
                path.addLine(to: CGPoint(x: rect.width - 15, y: rect.height))
                path.addLine(to: CGPoint(x: 15, y: rect.height))
            }
        }
    }

}
