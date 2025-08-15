//
//  Stock.swift
//  QapitalStocks
//
//  Created by Vahagn Nurijanyan on 2024-11-24.
//

import Foundation

struct Stock: Codable, Identifiable, Hashable {
    let id = UUID()
    let ticker: String
    let name: String
    let currentPrice: Double
}
