//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by kazutaka on 2020/12/04.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class ExchangeRateListViewController: UIViewController {

    var viewModel: ViewModel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var validationMessageLabel: UILabel!
    @IBOutlet weak var currencyPickerButton: UIButton!
    @IBOutlet weak var errorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
        viewModel.reload()
    }
    
    func setup() {
        amountField.addDoneButton()
    }
    
    func bind() {
        viewModel.amountString <~ amountField.reactive.continuousTextValues
        validationMessageLabel.reactive.isHidden <~ viewModel.shouldShowInvalidMessage.negate()
        collectionView.reactive.reloadData <~ viewModel.shouldReloadCollectionView
        currencyPickerButton.reactive.title <~ viewModel.standardCurrency
        currencyPickerButton.reactive.isEnabled <~ viewModel.isCurrencyPickerButtonEnabled
        errorView.reactive.isHidden <~ viewModel.isFetchingSuccessful
    }
    
    @IBAction func didTapCurrencyPickerButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: CurrencyPickerViewController.self))
        let viewController = storyboard.instantiateViewController(identifier: "CurrencyPickerViewController") as! CurrencyPickerViewController
        viewController.viewModel.availableCurrencies = viewModel.availableCurrencies
        viewController.viewModel.selectedCurrency = viewModel.standardCurrency.value
        viewController.viewModel.selectedCurrencyHandler = viewModel.selectedCurrencyHandler(currency:)
        show(viewController, sender: self)
    }
    
    @IBAction func didTapReloadButton(_ sender: Any) {
        viewModel.reload()
    }
}

extension ExchangeRateListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "paired_rate", for: indexPath) as! ExchangeRateCell
        cell.currencyLabel.text = viewModel.currency(for: indexPath)
        cell.rateLabel.text = viewModel.currencyRate(for: indexPath) ?? "-"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pairedCurrencyCount
    }
    
}
