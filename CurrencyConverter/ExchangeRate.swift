//
//  ExchangeRate.swift
//  CurrencyConverter
//
//  Created by kazutaka on 2020/12/09.
//

import Foundation

class ExchangeRate {
    private let sourceCurrency: String
    private let quotes: [String: Float]
    private lazy var rateTable: [String: Float] = {
        var table = [String: Float]()
        // stripping off the source currency from dictionary key
        for (key, value) in quotes {
            table[key.replacingOccurrences(of: sourceCurrency, with: "")] = value
        }
        return table
    }()
    
    var availableCurrencies: [String] {
        return rateTable.keys.map { $0 } + [sourceCurrency]
    }
    
    init(sourceCurrency: String, quotes: [String: Float]) {
        self.sourceCurrency = sourceCurrency
        self.quotes = quotes
    }
    
    func rates(for standardCurrency: String, pairedCurrency: String) -> Float? {
        if standardCurrency == pairedCurrency {
            return 1
        } else if standardCurrency == sourceCurrency {
            return rateTable[pairedCurrency]
        } else if pairedCurrency == sourceCurrency {
            guard let standardRate = rateTable[standardCurrency], standardRate > 0 else { return nil }
            return 1 / standardRate
        } else if rateTable.keys.contains(standardCurrency) && rateTable.keys.contains(pairedCurrency) {
            guard let standardRate = rateTable[standardCurrency],
                  let pairedRate = rateTable[pairedCurrency] else { return nil }
            // JPY/AUD = (USD/AUD) / (USD/JPY)
            return pairedRate / standardRate
        }
        return nil
    }
}
