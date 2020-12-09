//
//  ExchangeRateFetcherSpec.swift
//  CurrencyConverterTests
//
//  Created by kazutaka on 2020/12/07.
//

import Quick
import Nimble
import Swinject
@testable import CurrencyConverter

class ExchangeRateFetcherSpec : QuickSpec {
    struct StubDataGateway: Gateway {
        private static let json =
            "{" +
                "\"success\":true," +
                "\"terms\":\"https:\\/\\/currencylayer.com\\/terms\"," +
                "\"privacy\":\"https:\\/\\/currencylayer.com\\/privacy\"," +
                "\"timestamp\":1607272865," +
                "\"source\":\"USD\"," +
                "\"quotes\":{" +
                    "\"USDAED\":3.673042," +
                    "\"USDAFN\":76.950404," +
                    "\"USDALL\":101.850403" +
                "}" +
            "}"

        func request(responseHandler: @escaping (Data?) -> ()) {
            let data = StubDataGateway.json.data(using: .utf8, allowLossyConversion: false)
            responseHandler(data)
        }
    }

    override func spec() {
        var container: Container!
        beforeEach {
            container = Container()

            // Registrations for the gateway using Alamofire.
            container.register(Gateway.self) { _ in DataGateway() }
            container.register(ExchangeRateFetcher.self) { r in
                ExchangeRateFetcher(dataGateway: r.resolve(Gateway.self)!)
            }

            // Registration for the stub network.
            container.register(Gateway.self, name: "stub") { _ in
                StubDataGateway()
            }
            container.register(ExchangeRateFetcher.self, name: "stub") { r in
                ExchangeRateFetcher(dataGateway: r.resolve(Gateway.self, name: "stub")!)
            }
        }

        it("returns exchange rate.") {
            var response: ExchangeRateFetcher.Response?
            let fetcher = container.resolve(ExchangeRateFetcher.self)!
            fetcher.fetch { response = $0 }

            expect(response).toEventuallyNot(beNil())
            expect(response?.isSuccessful).toEventually(beTrue())
            expect(response?.quotes.count).toEventually(beGreaterThan(0))
        }
        it("fills exchange rate data.") {
            var response: ExchangeRateFetcher.Response?
            let fetcher = container.resolve(ExchangeRateFetcher.self, name: "stub")!
            fetcher.fetch { response = $0 }

            expect(response?.sourceCurrency).to(equal("USD"))
            expect(response?.quotes["USDAED"]).to(equal(3.673042))
            expect(response?.quotes["USDAFN"]).to(equal(76.950404))
            expect(response?.quotes["USDALL"]).to(equal(101.850403))
        }
    }
}

