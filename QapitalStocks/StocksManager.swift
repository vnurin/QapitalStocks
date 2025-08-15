//
//  StocksManager.swift
//  QapitalStocks
//
//  Created by Vahagn Nurijanyan on 2024-11-24.
//

import Foundation
import SwiftUI

class StocksManager: ObservableObject {
    
    /*    enum Error: LocalizedError {
            case urlError
            case downloadError
            case decodingError
            
            var errorDescription: String? {
                switch self {
                case .urlError:
                    return "Provided URL is invalid!"
                case .downloadError:
                    return "Network isn't accessible!"
                case .decodingError:
                    return "Stock data failed!"
                }
            }
        }*/

    struct Constants {
        static let urlString = "https://apple.com"
        static let title = "Stocks"
        static let searchFields = "Search by Name or Ticker"
        static let noStocksMessage = "No stocks found!"
        static let alertMessage = "No network connection!"
        static let sampleStocks: [Stock] = [
            .init(ticker: "AAPL", name: "Apple Inc.", currentPrice: 123.45),
            .init(ticker: "GOOG", name: "Google Inc.", currentPrice: 67.89),
            .init(ticker: "MSFT", name: "Microsoft Corporation", currentPrice: 10.11)
        ]
    }
        
    var getRemotly: Bool
    var stocks: [Stock] {
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
    @Published var error: Error?
    @Published var isLoading = false
    
    init(getRemotly: Bool = false, stocks: [Stock] = []) {
        self.getRemotly = getRemotly
        self.stocks = stocks
        filterStocks()
    }
    
    func fetchStocks() async {
        getRemotly ? await fetchStocksRemotly() : await fetchStocksLocally()
    }
    
    private func fetchStocksRemotly() async {
        guard let url = URL(string: Constants.urlString) else {
            DispatchQueue.main.async { [weak self] in
                self?.error = URLError(URLError.badURL)
            }
            print("Provided URL is invalid!")
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
        }
        let fetchTask = Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            let stocks = try JSONDecoder().decode([Stock].self, from: data)
            return stocks
        }
        let result = await fetchTask.result
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            /*
            do {
                self?.stocks = try result.get()
            } catch {
                self?.error = error
            }
             */
            switch result {
            case .success(let stocks):
                self?.stocks = stocks
            case .failure(let error):
                self?.error = error
                print("Stock data failed!")
            }
        }
    }
    
    private func fetchStocksLocally() async {
        guard let url = Bundle.main.url(forResource: "stocks", withExtension: "json") else {
            DispatchQueue.main.async { [weak self] in
                self?.error = URLError(URLError.badURL)
            }
            print("Provided URL is invalid!")
            return
        }
        let fetchTask = Task {
            let data = try Data(contentsOf: url)
            let stocks = try JSONDecoder().decode([Stock].self, from: data)
            return stocks
        }
        let result = await fetchTask.result
        DispatchQueue.main.async { [weak self] in
            switch result {
            case .success(let stocks):
                self?.stocks = stocks
            case .failure(let error):
                self?.error = error
                print("Stock data failed!")
            }
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
