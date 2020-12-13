//
//  DataGateway.swift
//  CurrencyConverter
//
//  Created by kazutaka on 2020/12/05.
//

import Alamofire

protocol Gateway {
    func request(responseHandler: @escaping (Data?) -> ())
}

struct DataGateway: Gateway {
    
    let rateLimit: TimeInterval
    
    // 30 min
    init(rateLimit: TimeInterval = 30 * 60) {
        self.rateLimit = rateLimit
    }
    
    let exchangeRateRequest: URLRequest = {
        // free account does not let us use secure connection (https)
        let url = URL(string: "http://api.currencylayer.com/live?access_key=ac61db195ff8cc316e49808a6ab05245")!
        return URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
    }()
    
    // return cache if it exists. Cache is cleared every 30 min
    func request(responseHandler: @escaping (Data?) -> ()) {
        let lastCacheRemovedAtKey = "last_cache_removed_at"
        let date = UserDefaults.standard.date(forKey: lastCacheRemovedAtKey) ?? Date(timeIntervalSince1970: 0)
        if date.advanced(by: rateLimit) < Date() {
            URLCache.shared.removeCachedResponse(for: exchangeRateRequest)
            UserDefaults.standard.setValue(Date(), forKey: lastCacheRemovedAtKey)
        }
        AF.request(exchangeRateRequest)
            .response { response in
                responseHandler(response.data)
            }
    }
}
