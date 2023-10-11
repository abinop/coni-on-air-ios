//
//  ProducerRow.swift
//  coni-on-air
//

import SwiftUI

struct ProducerRow: View {
    @State var producer: Producer
    let producerNS: Namespace.ID

    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(producer.name)
                        .matchedGeometryEffect(id: producer.id + "_name", in: producerNS)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
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
                }
                Spacer()
                CacheAsyncImage(url: URL(string: producer.photo)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .matchedGeometryEffect(id: producer.id + "_image", in: producerNS)
                            .frame(width: 50, height: 50, alignment: .center)
                    case .failure:
                        Color.gray
                            .clipShape(Circle())
                            .shadow(radius: 2)
                            .frame(width: 50, height: 50, alignment: .center)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color("coni-darkgray"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
}
