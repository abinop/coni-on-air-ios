//
//  NewProducersView.swift
//  coni-on-air-ios
//

import SwiftUI

struct ProducerView: View {
    var producer: Producer
    let producerNS: Namespace.ID
    let onClose: (()->())
    @State var showText: Bool = false
    @State var isCircle = true
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                ZStack(alignment: .topLeading) {
                    CacheAsyncImage(url: URL(string: producer.photo)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .matchedGeometryEffect(id: producer.id + "_image", in: producerNS)
                                .frame(maxWidth: .infinity)
                        case .failure:
                            Color.gray
                                .frame(width: 75, height: 75, alignment: .center)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    if showText {
                        Button(action: {
                            onClose()
                        }, label: {
                            Image(systemName: "xmark")
                                .renderingMode(.template)
                                .tint(.white)
                                .padding()
                                .background(Color(uiColor: .darkGray), in: Circle())
                        })
                        .padding(.leading, 8)
                        .padding(.top, 16)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(producer.name)
                        .matchedGeometryEffect(id: producer.id + "_name", in: producerNS)
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                        .minimumScaleFactor(0.1)
                    HStack {
                        Image(systemName: "waveform.and.mic")
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                            .padding(.vertical, 4)
                        Text(producer.show)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.trailing, 8)
                    }
                    .background(Capsule().foregroundColor(Color("color-blue")))
                    .matchedGeometryEffect(id: producer.id + "_show", in: producerNS)
                    if showText {
                        AttributedText(attributedString: producer.attributedDesc)
                            .foregroundColor(.white)
                            .tint(.white)
                            .padding(.vertical)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color("coni-darkgray"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.white.opacity(0.1), radius: 1)
        .onAppear {
            withAnimation(.linear.delay(0.35)) {
                showText = true
            }
        }
    }

}
