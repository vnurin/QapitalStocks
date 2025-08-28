//
//  StocksManagerTests.swift
//  QapitalStocksTests
//
//  Created by Vahagn Nurijanyan on 2025-08-17.
//

import Testing
@testable import QapitalStocks

@Suite("StocksManager Tests")
struct StocksManagerTests {

    @Test("Remotly Test") func fetchStocksRemotlyTest() async throws {
        let vm = await StocksManager()
        try await #require(vm.monitor.isNetworkAvailable, "Must have internet connection!")
        let stocks = try await vm.fetchStocksRemotly()
        #expect(stocks.count > 0)
    }
}
