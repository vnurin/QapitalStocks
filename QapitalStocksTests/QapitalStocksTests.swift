//
//  QapitalStocksTests.swift
//  QapitalStocksTests
//
//  Created by Vahagn Nurijanyan on 2024-11-24.
//

import XCTest
@testable import QapitalStocks

final class QapitalStocksTests: XCTestCase {
    let networkService = NetworkService()
    private var session: URLSession!
    
    override func setUpWithError() throws {
        session = URLSession(configuration: .default)
        networkService.setUpNetworkMonitor()
    }
    
    override func tearDownWithError() throws {
        networkService.tearDownNetworkMonitor()
        session = nil
    }
    
    func testStocksAreFetchable() throws {
        try XCTSkipUnless(networkService.isNetworkAvailable, "Network is not available")
        var stocks: [Stock]?
        var statusCode: Int?
        var fetchError: Error?
        guard let url = URL(string: StocksManager.Constants.urlString) else {
            XCTFail(URLError(.badURL).localizedDescription)
            return
        }
        let promise = expectation(description: "End Of the Closure")
        session.dataTask(with: url) { data, response, error in
            if error != nil {
                fetchError = error
            } else {
                statusCode = (response as? HTTPURLResponse)?.statusCode
                if let data = data {
                    stocks = try? JSONDecoder().decode([Stock].self, from: data)
                }
            }
            promise.fulfill()
        }
        .resume()
        wait(for: [promise], timeout: 5)
        XCTAssertNil(fetchError, fetchError!.localizedDescription)
        XCTAssertEqual(statusCode, 200, "Response Status Code isn't 200")
        XCTAssertNotNil(stocks, "Stocks aren't initialized")
    }
    
    func testStocksAreFetchableFromFile() throws {
        var stocks: [Stock]?
        var fetchError: Error?
        guard let url = Bundle.main.url(forResource: "stocks.json", withExtension: nil) else {
            XCTFail(URLError(.badURL).localizedDescription)
            return
        }
        do {
            stocks = try JSONDecoder().decode([Stock].self, from: try Data(contentsOf: url))
        } catch {
            fetchError = error
        }
        XCTAssertNil(fetchError, fetchError!.localizedDescription)
        XCTAssertNotNil(stocks, "Stocks aren't initialized")
    }
    
}
