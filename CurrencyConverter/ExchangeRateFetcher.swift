//
//  ExchangeRateFetcher.swift
//  CurrencyConverter
//
//  Created by kazutaka on 2020/12/05.
//

import Foundation

struct ExchangeRateFetcher {
    let dataGateway: Gateway
    
    func fetch(response: (ExchangeRate?) -> ()) {
        dataGateway.request { data in
            guard let data = data,
                  let exchangeRate = try? JSONDecoder().decode(ExchangeRate.self, from: data),
                  exchangeRate.isSuccessful else {
                response(nil)
                return
            }
            response(exchangeRate)
        }
    }
}
