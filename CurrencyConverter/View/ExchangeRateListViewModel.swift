//
//  ExchangeRateListViewModel.swift
//  CurrencyConverter
//
//  Created by kazutaka on 2020/12/12.
//

import Foundation
import ReactiveSwift

fileprivate let defaultStandardCurrency = "--"

extension ExchangeRateListViewController {
    class ViewModel {
        let amountString = MutableProperty<String>("1.00")
        private(set) lazy var standardCurrency = Property<String>(_standardCurrency)
        private(set) lazy var isCurrencyPickerButtonEnabled = exchangeRate.map { $0 != nil }
        private(set) lazy var isFetchingSuccessful = fetchingStatusStream.output
        private(set) lazy var shouldReloadCollectionView = exchangeRate.signal.map(value: ())
        private(set) lazy var shouldShowInvalidMessage = amount.map { return $0 == nil }
        
        var pairedCurrencyCount: Int {
            guard let exchangeRate = exchangeRate.value else { return 0 }
            return exchangeRate.availableCurrencies.filter { $0 != _standardCurrency.value }.count
        }
        var availableCurrencies: [String]? {
            guard let exchangeRate = exchangeRate.value else { return nil }
            return exchangeRate.availableCurrencies
        }
        
        private let _standardCurrency = MutableProperty<String>(defaultStandardCurrency)
        private let exchangeRateFetcher: ExchangeRateFetcher
        private var exchangeRate = MutableProperty<ExchangeRate?>(nil)
        private let fetchingStatusStream = Signal<Bool, Never>.pipe()
        private let shouldFetchStream = Signal<Void, Never>.pipe()
        private lazy var amount: Property<Float?> = amountString.map { Float($0) }
        
        init(exchangeRateFetcher: ExchangeRateFetcher) {
            self.exchangeRateFetcher = exchangeRateFetcher
            bind()
        }

        private func bind() {
            shouldFetchStream.input <~ amount.signal
                .skipRepeats()
                .map(value: ())
                .merge(with: _standardCurrency.signal.map(value: ()))
            
            _standardCurrency <~ exchangeRate.signal.delay(0.2, on: QueueScheduler.main)
                .compactMap { [weak self] _ -> String? in
                    guard let currency = self?.availableCurrencies?.first,
                          self?._standardCurrency.value == defaultStandardCurrency else {
                        return  nil
                    }
                    return currency
                }
            
            shouldFetchStream.output.observeValues { [weak self] in
                self?.exchangeRateFetcher.fetch { [weak self] (response) -> Void in
                    guard let sourceCurrency = response?.sourceCurrency,
                          let quotes = response?.quotes else {
                        self?.fetchingStatusStream.input.send(value: false)
                        return
                    }
                    self?.exchangeRate.swap(ExchangeRate(sourceCurrency: sourceCurrency, quotes: quotes))
                    self?.fetchingStatusStream.input.send(value: true)
                }
            }

        }
        
        func currency(for indexPath: IndexPath) -> String? {
            guard let availableCurrencies = exchangeRate.value?.availableCurrencies else { return nil }
            return availableCurrencies.filter { $0 != _standardCurrency.value } [indexPath.row]
        }
        
        func currencyRate(for indexPath: IndexPath) -> String? {
            guard let exchangeRate = exchangeRate.value,
                  let amount = amount.value,
                  let pairedCurrency = currency(for: indexPath) else { return nil }
            guard let rate = exchangeRate.rates(for: _standardCurrency.value, pairedCurrency: pairedCurrency) else { return nil }
            return String(rate * amount)
        }
        
        func selectedCurrencyHandler(currency: String) {
            _standardCurrency.swap(currency)
        }
        
        func reload() {
            shouldFetchStream.input.send(value: ())
        }
        
    }
}
