//
//  CurrencyPickerViewController.swift
//  CurrencyConverter
//
//  Created by kazutaka on 2020/12/12.
//

import UIKit

class CurrencyPickerViewController: UIViewController {
    let viewModel = ViewModel()
    
}

extension CurrencyPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.availableCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currency_name", for: indexPath)
        cell.textLabel?.text = viewModel.currency(for: indexPath)
        cell.accessoryType = viewModel.accessoryType(for: indexPath)
        return cell
    }
}

extension CurrencyPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedRow = viewModel.selectedRow {
            tableView.cellForRow(at: IndexPath(row: 0, section: selectedRow))?.accessoryType = .none
        }
        tableView.dequeueReusableCell(withIdentifier: "currency_name", for: indexPath).accessoryType = .checkmark
        viewModel.selectedCurrencyHandler(viewModel.currency(for: indexPath)!)
        navigationController?.popViewController(animated: true)
    }
}
