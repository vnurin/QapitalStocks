//
//  NetworkService.swift
//  StocksTests
//
//  Created by Vahagn Nurijanyan on 2024-11-23.
//

import Foundation
import Network

final class NetworkService {
    private let monitor = NWPathMonitor() // Network Monitor
    var isNetworkAvailable = false

    func setUpNetworkMonitor() {
        // Monitor network changes
        monitor.pathUpdateHandler = { path in
            self.isNetworkAvailable = path.status == .satisfied
            DispatchQueue.main.async {
                if self.isNetworkAvailable {
                    print("Network is available.")
                } else {
                    print("Network is unavailable.")
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func tearDownNetworkMonitor() {
        monitor.cancel()
    }
}
