//
//  ExchangeRateListViewModelSpec.swift
//  CurrencyConverterTests
//
//  Created by kazutaka on 2020/12/13.
//

import Quick
import Nimble
import Swinject
@testable import CurrencyConverter

class ExchangeRateListViewModelSpec: QuickSpec {
    typealias ViewModel = ExchangeRateListViewController.ViewModel
    
    struct StubDataGateway: Gateway {
        private static let json =
            "{" +
                "\"success\":true," +
                "\"terms\":\"https:\\/\\/currencylayer.com\\/terms\"," +
                "\"privacy\":\"https:\\/\\/currencylayer.com\\/privacy\"," +
                "\"timestamp\":1607272865," +
                "\"source\":\"USD\"," +
                "\"quotes\":{" +
                    "\"USDAED\":3.0," +
                    "\"USDAFN\":4.0," +
                    "\"USDALL\":12.0" +
                "}" +
            "}"

        func request(responseHandler: @escaping (Data?) -> ()) {
            let data = StubDataGateway.json.data(using: .utf8, allowLossyConversion: false)
            responseHandler(data)
        }
    }
    
    struct FailedStubDataGateway: Gateway {
        func request(responseHandler: @escaping (Data?) -> ()) {
            responseHandler(nil)
        }
    }
    
    override func spec() {
        var container: Container!
        beforeEach {
            container = Container()

            // successful fetch
            container.register(Gateway.self) { _ in
                StubDataGateway()
            }
            container.register(ExchangeRateFetcher.self) { r in
                ExchangeRateFetcher(dataGateway: r.resolve(Gateway.self)!)
            }
            
            // failed fetch
            container.register(Gateway.self, name: "failed") { _ in
                FailedStubDataGateway()
            }
            container.register(ExchangeRateFetcher.self, name: "failed") { r in
                ExchangeRateFetcher(dataGateway: r.resolve(Gateway.self, name: "failed")!)
            }
        }
        
        it("returns the number of paired currency") {
            let viewModel = ViewModel(exchangeRateFetcher: container.resolve(ExchangeRateFetcher.self)!)
            expect(viewModel.pairedCurrencyCount).to(equal(0))
            viewModel.reload()
            expect(viewModel.pairedCurrencyCount).toEventually(equal(4))
            viewModel.selectedCurrencyHandler(currency: "USD")
            expect(viewModel.pairedCurrencyCount).toEventually(equal(3))
        }
        
        it("returns the standard currency and set the standard currency after successful fetch") {
            let viewModel = ViewModel(exchangeRateFetcher: container.resolve(ExchangeRateFetcher.self)!)
            expect(viewModel.standardCurrency.value).to(equal("--"))
            viewModel.reload()
            viewModel.selectedCurrencyHandler(currency: "USD")
            expect(viewModel.standardCurrency.value).toEventually(equal("USD"))
        }

        it("returns a flag for when currency picker button should be enabled.") {
            let viewModel = ViewModel(exchangeRateFetcher: container.resolve(ExchangeRateFetcher.self)!)
            expect(viewModel.isCurrencyPickerButtonEnabled.value).to(equal(false))
            viewModel.reload()
            expect(viewModel.isCurrencyPickerButtonEnabled.value).toEventually(equal(true))
        }
        
        it("knows if fetching is successful") {
            let viewModel = ViewModel(exchangeRateFetcher: container.resolve(ExchangeRateFetcher.self)!)
            waitUntil { done in
                viewModel.isFetchingSuccessful.observeValues {
                    expect($0).to(equal(true))
                    done()
                }
                viewModel.reload()
            }
        }
        
        it("knows if fetching failed") {
            let viewModel = ViewModel(exchangeRateFetcher: container.resolve(ExchangeRateFetcher.self, name: "failed")!)
            waitUntil { done in
                viewModel.isFetchingSuccessful.observeValues {
                    expect($0).to(equal(false))
                    done()
                }
                viewModel.reload()
            }
        }
        
        it("knows when to reload collection view.") {
            let viewModel = ViewModel(exchangeRateFetcher: container.resolve(ExchangeRateFetcher.self)!)
            waitUntil { done in
                viewModel.shouldReloadCollectionView.observeValues {
                    done()
                }
                viewModel.reload()
            }
        }
        
        it("knows if invalid message should appear") {
            let viewModel = ViewModel(exchangeRateFetcher: container.resolve(ExchangeRateFetcher.self)!)
            viewModel.reload()
            expect(viewModel.shouldShowInvalidMessage.value).to(equal(false))
            viewModel.amountString.swap("abc")
            expect(viewModel.shouldShowInvalidMessage.value).to(equal(true))
            viewModel.amountString.swap("111")
            expect(viewModel.shouldShowInvalidMessage.value).to(equal(false))
            viewModel.amountString.swap(".111")
            expect(viewModel.shouldShowInvalidMessage.value).to(equal(false))
            viewModel.amountString.swap("1.11")
            expect(viewModel.shouldShowInvalidMessage.value).to(equal(false))
        }
        
        it("returns a currency for a given indexPath") {
            let viewModel = ViewModel(exchangeRateFetcher: container.resolve(ExchangeRateFetcher.self)!)
            viewModel.reload()
            expect(viewModel.currency(for: IndexPath(row: 0, section: 0))).toEventually(equal("AFN"))
            expect(viewModel.currency(for: IndexPath(row: 1, section: 0))).toEventually(equal("ALL"))
            expect(viewModel.currency(for: IndexPath(row: 2, section: 0))).toEventually(equal("USD"))
            viewModel.selectedCurrencyHandler(currency: "USD")
            expect(viewModel.currency(for: IndexPath(row: 0, section: 0))).to(equal("AED"))
            expect(viewModel.currency(for: IndexPath(row: 1, section: 0))).to(equal("AFN"))
            expect(viewModel.currency(for: IndexPath(row: 2, section: 0))).to(equal("ALL"))
        }
        
        it("returns a currency rate for a given indexPath") {
            let viewModel = ViewModel(exchangeRateFetcher: container.resolve(ExchangeRateFetcher.self)!)
            viewModel.reload()
            viewModel.selectedCurrencyHandler(currency: "USD")
            expect(viewModel.currencyRate(for: IndexPath(row: 0, section: 0))).toEventually(equal("3.0"))
            expect(viewModel.currencyRate(for: IndexPath(row: 1, section: 0))).toEventually(equal("4.0"))
            expect(viewModel.currencyRate(for: IndexPath(row: 2, section: 0))).toEventually(equal("12.0"))
        }
    }
}
