//
//  NetworkMonitor.swift
//  StocksTests
//
//  Created by Vahagn Nurijanyan on 2024-11-23.
//

//import Foundation
import Network
import SwiftUI

@Observable final class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    var isNetworkAvailable = true

    init() {
        monitor.pathUpdateHandler = { [ weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

}
