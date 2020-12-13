//
//  UITextField+DoneButton.swift
//  CurrencyConverter
//
//  Created by kazutaka on 2020/12/13.
//

import UIKit

extension UITextField {
    func addDoneButton() {
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        ]
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
    }

    @objc func doneButtonTapped() { self.resignFirstResponder() }
}
