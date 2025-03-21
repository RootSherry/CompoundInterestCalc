//
//  CurrencyManager.swift
//  复利计算器
//
//  Created by ROOT. on 2025/3/20.
//

import Foundation
import SwiftUI

struct Currency: Identifiable, Codable {
    let id = UUID()
    let code: String
    let symbol: String
    let name: String
}

class CurrencyManager: ObservableObject {
    @Published var selectedCurrency: Currency {
        didSet {
            saveSelectedCurrency()
        }
    }
    
    @Published var currencies: [Currency]
    
    private let currencySaveKey = "selectedCurrency"
    
    init() {
        // 默认货币列表
        let defaultCurrencies = [
            Currency(code: "CNY", symbol: "¥", name: "人民币"),
            Currency(code: "USD", symbol: "$", name: "美元"),
            Currency(code: "EUR", symbol: "€", name: "欧元"),
            Currency(code: "GBP", symbol: "£", name: "英镑"),
            Currency(code: "JPY", symbol: "¥", name: "日元"),
            Currency(code: "HKD", symbol: "HK$", name: "港币"),
            Currency(code: "KRW", symbol: "₩", name: "韩元"),
            Currency(code: "AUD", symbol: "A$", name: "澳元")
        ]
        
        self.currencies = defaultCurrencies
        
        // 尝试加载保存的货币选择
        if let savedData = UserDefaults.standard.data(forKey: currencySaveKey),
           let savedCurrency = try? JSONDecoder().decode(Currency.self, from: savedData) {
            self.selectedCurrency = savedCurrency
        } else {
            // 默认使用人民币
            self.selectedCurrency = defaultCurrencies[0]
        }
    }
    
    func saveSelectedCurrency() {
        if let encoded = try? JSONEncoder().encode(selectedCurrency) {
            UserDefaults.standard.set(encoded, forKey: currencySaveKey)
        }
    }
    
    func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        if let formattedValue = formatter.string(from: NSNumber(value: amount)) {
            return selectedCurrency.symbol + formattedValue
        }
        
        return selectedCurrency.symbol + String(format: "%.2f", amount)
    }
}