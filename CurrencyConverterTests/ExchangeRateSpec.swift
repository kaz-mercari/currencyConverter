//
//  ExchangeRateSpec.swift
//  CurrencyConverterTests
//
//  Created by kazutaka on 2020/12/10.
//

import Quick
import Nimble
import Swinject
@testable import CurrencyConverter

class ExchangeRateSpec: QuickSpec {
    override func spec() {
        
        it("returns available currencies.") {
            let exchangeRate = ExchangeRate(
                sourceCurrency: "USD",
                quotes: ["USDJPY": 3, "USDAUD": 12, "USDCAD": 3]
            )
            expect(exchangeRate.availableCurrencies).to(contain(["USD","JPY","AUD","CAD"]))
        }
        
        it("returns rates for source currency rate.") {
            let exchangeRate = ExchangeRate(
                sourceCurrency: "USD",
                quotes: ["USDJPY": 3, "USDAUD": 12]
            )
            expect(exchangeRate.rates(for: "USD", pairedCurrency: "JPY")).to(equal(3))
            expect(exchangeRate.rates(for: "JPY", pairedCurrency: "USD")).to(beCloseTo(0.3333))
            expect(exchangeRate.rates(for: "USD", pairedCurrency: "AUD")).to(equal(12))
            expect(exchangeRate.rates(for: "AUD", pairedCurrency: "USD")).to(beCloseTo(0.08333))
            expect(exchangeRate.rates(for: "JPY", pairedCurrency: "AUD")).to(equal(4))
            expect(exchangeRate.rates(for: "AUD", pairedCurrency: "JPY")).to(equal(0.25))
        }
        
    }
}


