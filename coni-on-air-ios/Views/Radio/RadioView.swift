//
//  LiveView.swift
//  coni-on-air
//

import SwiftUI

struct RadioView: View {
    @StateObject private var viewModel = ViewModel()
    @State var appeared: Bool = false

    var body: some View {
        VStack {
            ZStack {
                Image("coni-logo-flat")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180)
                    .padding()
            }
            if appeared {
                VStack(spacing: 4) {
                    Text(viewModel.nowPlayingData?.songTitle != nil ? "Now playing:" : " ")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                    Text((viewModel.nowPlayingData?.songTitle ?? " ").uppercased())
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    SwimplyPlayIndicator(state: $viewModel.playingState, color: .white)
                        .fixedSize()
                        .padding(.top)
                    if viewModel.isLoadingPlayer {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 75, height: 75)
                            .overlay {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            }
                            .padding()
                        
                    } else {
                        Button(action: {
                            viewModel.playPTapped()
                        }, label: {
                            VStack {
                                if viewModel.isPlaying {
                                    Image(systemName: "pause.circle.fill")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(Color.white)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 75, height: 75)
                                } else {
                                    Image(systemName: "play.circle.fill")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(Color.white)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 75, height: 75)
                                }
                            }
                        })
                        .padding()
                        .disabled(viewModel.nowPlayingData?.url == nil || viewModel.isLoadingPlayer)
                    }
                }
                .padding(.top)
            }
        }
        .padding()
        .background(
            Color("color-black")
                .edgesIgnoringSafeArea(.all)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        )
        .alert("PLAYER_ERROR", isPresented: $viewModel.playerFacedError) {
            Button("OK") {}
        }
        .onAppear(perform: {
            withAnimation {
                appeared = true
            }
        })
    }
}

struct LiveView_Previews: PreviewProvider {
    static var previews: some View {
        RadioView()
    }
}
