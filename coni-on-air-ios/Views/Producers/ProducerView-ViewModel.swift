//
//  ProducerView-ViewModel.swift
//  coni-on-air
//

import Foundation

extension ProducerView {
    @MainActor class ViewModel: ObservableObject {
        var producer: Producer!
    }
}
