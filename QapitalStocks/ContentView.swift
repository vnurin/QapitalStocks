//
//  ContentView.swift
//  QapitalStocks
//
//  Created by Vahagn Nurijanyan on 2024-11-24.
//

import SwiftUI

struct ContentView: View {
    @State var viewModel = StocksManager()
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    ForEach(viewModel.shownStocks) { stock in
                        NavigationLink(value:stock) {
                            StockView(stock: stock)
                        }
                    }
                }
                .navigationTitle(StocksManager.Constants.title)
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $viewModel.searchText, prompt: StocksManager.Constants.searchField)
                .refreshable {
                    viewModel.loadData()
                }
                .navigationDestination(for: Stock.self) { stock in
                    DetailsView(stock: stock)
                }
            }
            .onAppear {
                guard viewModel.stocks.isEmpty else { return }
                viewModel.loadData()
            }
            if !viewModel.searchText.isEmpty && !viewModel.stocks.isEmpty && viewModel.shownStocks.isEmpty {
                Text(StocksManager.Constants.noStocksMessage)
                    .font(.title2)
            }
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2.0)
            }
        }
        .alert(isPresented: $viewModel.monitor.isNetworkAvailable
               , content: {
            Alert(title: Text("Network Status"), message: Text("No Internet Connection!"))
        })
        .alert(isPresented: Binding(get: { viewModel.error != nil }, set: { _ in viewModel.error = nil })) {
            Alert(title: Text("Error"), message: Text(viewModel.error?.localizedDescription ?? "Error!"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: StocksManager(stocks: StocksManager.Constants.sampleStocks))
    }
}
