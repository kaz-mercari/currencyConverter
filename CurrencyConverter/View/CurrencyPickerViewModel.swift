//
//  CurrencyPickerViewModel.swift
//  CurrencyConverter
//
//  Created by kazutaka on 2020/12/13.
//

import UIKit

extension CurrencyPickerViewController {
    class ViewModel {
        var availableCurrencies: [String]!
        var selectedCurrency: String!
        var selectedCurrencyHandler: ((String) -> Void)!
        lazy var selectedRow = availableCurrencies.firstIndex(of: selectedCurrency)
        
        func currency(for indexPath: IndexPath) -> String? {
            return availableCurrencies[indexPath.row]
        }
        
        func accessoryType(for indexPath: IndexPath) -> UITableViewCell.AccessoryType {
            return currency(for: indexPath) == selectedCurrency ? .checkmark : .none
        }
    }
}
