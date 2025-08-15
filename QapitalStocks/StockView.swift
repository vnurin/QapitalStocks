//
//  StockView.swift
//  QapitalStocks
//
//  Created by Vahagn Nurijanyan on 2024-11-24.
//

import SwiftUI

struct StockView: View {
    let stock: Stock
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.name)
                    .font(.title2)
                    .fontWeight(.medium)
                Text(stock.ticker)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
            }
            Spacer()
            Text(stock.currentPrice, format: .currency(code: "USD"))
                .font(.system(.headline))
        }
        .padding()
    }
}

#Preview {
    StockView(stock: StocksManager.Constants.sampleStocks.first!)
}
