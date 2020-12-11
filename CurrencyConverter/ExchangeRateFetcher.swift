//
//  ExchangeRateFetcher.swift
//  CurrencyConverter
//
//  Created by kazutaka on 2020/12/05.
//

import Foundation

struct ExchangeRateFetcher {
    let dataGateway: Gateway

    struct Response: Decodable {
        let isSuccessful: Bool
        let sourceCurrency: String
        let quotes: [String: Float]
        lazy var exchangeRate = ExchangeRate(sourceCurrency: sourceCurrency, quotes: quotes)
        
        enum CodingKeys: String, CodingKey {
            case isSuccessful = "success"
            case sourceCurrency = "source"
            case quotes
        }
    }

    
    func fetch(responseHandler: @escaping (Response?) -> ()) {
        dataGateway.request { data in
            guard let data = data,
                  let exchangeRate = try? JSONDecoder().decode(Response.self, from: data),
                  exchangeRate.isSuccessful else {
                responseHandler(nil)
                return
            }
            responseHandler(exchangeRate)
        }
    }
}
