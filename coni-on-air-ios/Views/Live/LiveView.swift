//
//  LiveView.swift
//  coni-on-air-ios
//
//  Created by Alexandros Binopoulos on 11/10/23.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        // Ensure the background color is transparent or set to your desired color
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        
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

struct LiveView: View {
    var body: some View {
        WebView(urlString: "https://coni-onair.com/live.php")
            .edgesIgnoringSafeArea(.all) // This should allow WebView to fill the entire screen
            .background(
                Color("color-black")
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            )
    }
}

// Preview
struct LiveView_Previews: PreviewProvider {
    static var previews: some View {
        LiveView()
    }
}
