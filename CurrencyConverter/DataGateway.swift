//
//  DataGateway.swift
//  CurrencyConverter
//
//  Created by kazutaka on 2020/12/05.
//

import Alamofire

protocol Gateway {
    func request(response: (Data?) -> ())
}

struct DataGateway: Gateway {
    // 30 min
    let rateLimit: TimeInterval = 30 * 60
    
    let exchangeRateRequest: URLRequest = {
        let url = URL(string: "http://api.currencylayer.com/live?access_key=ac61db195ff8cc316e49808a6ab05245")!
        return URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
    }()
    
    func request(response: (Data?) -> ()) {
        let lastFetchedAtKey = "last_fetched_at"
        
        if let date = UserDefaults.standard.date(forKey: lastFetchedAtKey),
           date.advanced(by: rateLimit) < Date() {
            URLCache.shared.removeCachedResponse(for: exchangeRateRequest)
        }
        AF.request(exchangeRateRequest)
            .response { response in
                debugPrint(response)
                UserDefaults.standard.setValue(Date(), forKey: lastFetchedAtKey)
            }
    }
}
