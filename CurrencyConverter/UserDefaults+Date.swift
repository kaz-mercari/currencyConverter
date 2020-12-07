//
//  UserDefaults+Date.swift
//  CurrencyConverter
//
//  Created by kazutaka on 2020/12/05.
//

import Foundation

extension UserDefaults {
    func date(forKey: String) -> Date? {
        let value = self.object(forKey: forKey)
        return value as? Date
    }
}
