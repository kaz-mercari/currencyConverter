//
//  SwinjectStoryboard+Setup.swift
//  CurrencyConverter
//
//  Created by kazutaka on 2020/12/12.
//

import SwinjectStoryboard

extension SwinjectStoryboard {
    class func setup() {
        defaultContainer.storyboardInitCompleted(ExchangeRateListViewController.self) { (resolver, vc) in
            vc.viewModel = resolver.resolve(ExchangeRateListViewController.ViewModel.self)
        }
        defaultContainer.register(ExchangeRateListViewController.ViewModel.self) {
            return ExchangeRateListViewController.ViewModel(exchangeRateFetcher: $0.resolve(ExchangeRateFetcher.self)!)
        }
        defaultContainer.register(ExchangeRateFetcher.self) {
            return ExchangeRateFetcher(dataGateway: $0.resolve(Gateway.self)!)
        }
        defaultContainer.register(Gateway.self) { _ in 
            return DataGateway()
        }
    }
}

