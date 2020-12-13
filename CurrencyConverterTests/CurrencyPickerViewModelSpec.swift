//
//  CurrencyPickerViewModelSpec.swift
//  CurrencyConverterTests
//
//  Created by kazutaka on 2020/12/13.
//

import Quick
import Nimble
import Swinject
@testable import CurrencyConverter

class CurrencyPickerViewModelSpec: QuickSpec {
    typealias ViewModel = CurrencyPickerViewController.ViewModel
    override func spec() {
        it("returns currency for an indexPath") {
            let viewModel = ViewModel()
            viewModel.availableCurrencies = ["AUD", "JPY", "USD"]
            viewModel.selectedCurrency = "JPY"
            expect(viewModel.currency(for: IndexPath(row: 0, section: 0))).to(equal("AUD"))
            expect(viewModel.currency(for: IndexPath(row: 1, section: 0))).to(equal("JPY"))
            expect(viewModel.currency(for: IndexPath(row: 2, section: 0))).to(equal("USD"))
        }
        it("returns accessoryType for an indexPath") {
            let viewModel = ViewModel()
            viewModel.availableCurrencies = ["AUD", "JPY", "USD"]
            viewModel.selectedCurrency = "JPY"
            expect(viewModel.accessoryType(for: IndexPath(row: 0, section: 0))).to(equal(UITableViewCell.AccessoryType.none))
            expect(viewModel.accessoryType(for: IndexPath(row: 1, section: 0))).to(equal(UITableViewCell.AccessoryType.checkmark))
            expect(viewModel.accessoryType(for: IndexPath(row: 2, section: 0))).to(equal(UITableViewCell.AccessoryType.none))
        }
    }
}
