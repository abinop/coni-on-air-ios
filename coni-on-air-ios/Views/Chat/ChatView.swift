//
//  ChatView.swift
//  coni-on-air
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ViewModel()
    @State var visibleItems: Set<String> = []
    @State private var sheetHeight: CGFloat = .zero
    @State var scrollProxy: ScrollViewProxy?

    var body: some View {
        ZStack {
            VStack {
                ScrollViewReader { value in
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(viewModel.messages) { message in
                                MessageRow(message: message)
                                    .onAppear {
                                        visibleItems.insert(message.id)
                                    }
                                    .onDisappear {
                                        visibleItems.remove(message.id)
                                    }
                                    .id(message.id)
                            }.onChange(of: viewModel.messages) { _ in
                                scrollToBottom(proxy: value)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .clipShape(Rectangle())
                    .onAppear {
                        scrollProxy = value
                    }
                }
                VStack(spacing: 16) {
                    Button {
                        withAnimation {
                            viewModel.isNewMessageVisible = true
                        }

                    } label: {
                        HStack {
                            Image(systemName: "plus.message.fill")
                            Text("NEW_MESSAGE")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.gray)
                }
                .padding()
                .background(Color.clear)
                Color.clear
                    .frame(height: 70)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(Color.clear)
        .navigationTitle("CHAT")
        .background(Color("color-black").edgesIgnoringSafeArea(.all))
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $viewModel.isNewMessageVisible) {
            VStack {
                Spacer(minLength: 100)
                SendMessageView(name: $viewModel.name, message: $viewModel.newMessage) {
                    viewModel.isNewMessageVisible = false
                } onSend: {
                    viewModel.sendMessage()
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(ClearBackgroundView())
        }
        .alert("SEND_MESSAGE_ERROR", isPresented: $viewModel.shouldShowNewMessageError) {
            Button("CANCEL", role: .cancel) {
                viewModel.newMessage = ""
            }
            Button("TRY_AGAIN") {
                viewModel.isNewMessageVisible = true
            }
        }
    }

    func scrollToBottom(proxy: ScrollViewProxy) {
        guard viewModel.messages.count >= 2,
              let lastMessage = viewModel.messages.last,
              let firstMessage = viewModel.messages.first
        else {
            return
        }
        let mess = viewModel.messages[viewModel.messages.count-2]
        if visibleItems.contains(mess.id) || visibleItems.contains(firstMessage.id) {
            withAnimation {
                proxy.scrollTo(lastMessage.id)
            }
        }
    }
}

struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return InnerView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }

    private class InnerView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = UIColor.clear
        }

    }
}
