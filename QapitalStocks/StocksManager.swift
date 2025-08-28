//
//  StocksManager.swift
//  QapitalStocks
//
//  Created by Vahagn Nurijanyan on 2024-11-24.
//

//import Foundation
import SwiftUI

@MainActor
class StocksManager: ObservableObject {
    
    //customized errors
    enum Error: LocalizedError, Equatable {
        case urlError
        case serverError(code: Int)
        case jsonError
        case unknownError
        
        var errorDescription: String? {
            switch self {
            case .urlError:
                return "Provided URL is invalid!"
            case .serverError(let code):
                return "Server error (\(code))!"
            case .jsonError:
                return "Stock data failed!"
            case .unknownError:
                return "Unknown error!"
            }
        }
    }
    
    struct Constants {
        static let baseUrlString = "https://api.tradewave.net/v2/"
        static let title = "Stocks"
        static let searchField = "Search by Name or Ticker"
        static let noStocksMessage = "No stocks found!"
        static let sampleStocks: [Stock] = [
            .init(ticker: "AAPL", name: "Apple Inc.", currentPrice: 123.45),
            .init(ticker: "GOOG", name: "Google Inc.", currentPrice: 67.89),
            .init(ticker: "MSFT", name: "Microsoft Corporation", currentPrice: 10.11)
        ]
    }
        
    @Published var monitor = NetworkMonitor()
    
    //use Local or remote data
    var getRemotly: Bool
    private let pageSize = 50
    private var pageNumber = 0
    private var urlString: String {
        StocksManager.Constants.baseUrlString + "exchanges/NASDAQ/symbols?page=\(pageNumber)&pageSize=\(pageSize)"
    }
    @Published var stocks: [Stock] {
        didSet {
            filterStocks()
        }
    }
    
    @AppStorage("searchText") var searchText = ""
    {
        didSet {
            filterStocks()
        }
    }
    @Published var shownStocks = [Stock]()
    @Published var error: StocksManager.Error?
    @Published var isLoading = false
    
    init(getRemotly: Bool = false, stocks: [Stock] = []) {
        self.getRemotly = getRemotly
        self.stocks = stocks
        filterStocks()
    }
    
    func loadData() {
        Task {
            await fetchStocks()
        }
    }
    
    private func fetchStocks() async {
        isLoading = true
        do {
            stocks = getRemotly ? try await fetchStocksRemotly() : try await fetchStocksLocally()
        } catch is StocksManager.Error {
            self.error = error
        } catch {
            self.error = .unknownError
        }
        isLoading = false
    }
    
     func fetchStocksRemotly() async throws -> [Stock] {
        
         guard let url = URL(string: urlString) else {
            throw Error.urlError
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw Error.serverError(code: httpResponse.statusCode)
        }
         if let stocks = try? JSONDecoder().decode([Stock].self, from: data) {
             return stocks
         }
         throw Error.jsonError
    }

    private func fetchStocksLocally() async throws -> [Stock] {
        guard let url = Bundle.main.url(forResource: "stocks", withExtension: "json") else {
            throw Error.urlError
        }
        let data = try Data(contentsOf: url)
        do {
            let stocks = try JSONDecoder().decode([Stock].self, from: data)
            return stocks
        }
        catch {
            throw Error.jsonError
        }
    }
    
    private func filterStocks() {
        if searchText.isEmpty {
            shownStocks = stocks
            return
        }
        let searchText = searchText.uppercased()
        shownStocks = stocks.filter{ $0.name.uppercased().contains(searchText) || $0.ticker.contains(searchText) }
    }
    
}
