//
//  LiveView.swift
//  coni-on-air-ios
//
//  Created by Alexandros Binopoulos on 11/10/23.
//

import SwiftUI
import WebKit

// WebView wrapped in a UIViewRepresentable
struct WebView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // Implement WKNavigationDelegate methods if needed
    }
}

// LiveView containing the full-screen WebView
struct LiveView: View {
    var body: some View {
        NavigationView {
            WebView(urlString: "https://coni-onair.com/live.php")
                .edgesIgnoringSafeArea(.all)
        }
    }
}

// Preview
struct LiveView_Previews: PreviewProvider {
    static var previews: some View {
        LiveView()
    }
}
