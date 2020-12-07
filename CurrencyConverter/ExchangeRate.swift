//
//  ExchangeRate.swift
//  CurrencyConverter
//
//  Created by kazutaka on 2020/12/05.
//

import Foundation

struct ExchangeRate: Decodable {
    let isSuccessful: Bool
    let sourceCurrency: String
    let quotes: [String: Float]
    enum CodingKeys: String, CodingKey {
        case isSuccessful = "success"
        case sourceCurrency = "source"
        case quotes
    }
}
