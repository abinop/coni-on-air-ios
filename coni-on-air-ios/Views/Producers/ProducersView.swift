//
//  ProducersView.swift
//  coni-on-air
//

import SwiftUI

struct ProducersView: View {
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var tabData: TabViewModel
    @Namespace private var producerNS
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack {
                            Image("coni-logo-flat")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 90)
                                .padding()
                            ForEach(viewModel.producers) { producer in
                                Color.clear
                                    .id(producer.id)
                                    .frame(height: 1)
                                VStack(spacing: 0) {
                                    if viewModel.selectedProducer?.id != producer.id {
                                        Button {
                                            withAnimation {
                                                proxy.scrollTo(producer.id, anchor: .top)
                                                tabData.isVisible = false
                                                viewModel.selectedProducer = producer
                                            }
                                        } label: {
                                            ProducerRow(producer: producer, producerNS: producerNS)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                   }
                                }
                            }
                            .scrollContentBackground(.hidden)
                            Color.clear
                                .frame(height: viewModel.selectedProducer == nil ? 80 : 180)
                        }
                    }
                    .clipShape(Rectangle())
                }
            }
            .opacity(viewModel.selectedProducer == nil ? 1 : 0.15)
            .toolbar(.hidden, for: .navigationBar)
            .background(Color("color-black").edgesIgnoringSafeArea(.all))
        }
        .overlay {
            if let selectedProducer = viewModel.selectedProducer {
                ScrollView {
                    ProducerView(producer: selectedProducer, producerNS: producerNS, onClose: {
                        withAnimation {
                            viewModel.selectedProducer = nil
                            tabData.isVisible = true
                        }
                    })
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                }
            }
        }
    }
}

struct ProducersView_Previews: PreviewProvider {
    static var previews: some View {
        ProducersView()
    }
}
