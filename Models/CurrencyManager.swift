//
//  CurrencyManager.swift
//  复利计算器
//
//  Created by ROOT. on 2025/3/20.
//

import Foundation
import SwiftUI

/// 货币模型
/// Represents a currency with its code, symbol, and localized name
struct Currency: Identifiable, Codable, Hashable {
    let id: UUID
    let code: String
    let symbol: String
    let name: String
    
    init(id: UUID = UUID(), code: String, symbol: String, name: String) {
        self.id = id
        self.code = code
        self.symbol = symbol
        self.name = name
    }
    
    /// 用于 Picker 选择比较
    static func == (lhs: Currency, rhs: Currency) -> Bool {
        return lhs.code == rhs.code
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}

/// 货币管理器
/// Manages currency selection and formatting throughout the app
class CurrencyManager: ObservableObject {
    @Published var selectedCurrency: Currency {
        didSet {
            saveSelectedCurrency()
        }
    }
    
    @Published var currencies: [Currency]
    
    private let currencySaveKey = "selectedCurrency"
    
    /// 默认支持的货币列表
    static let defaultCurrencies = [
        Currency(code: "CNY", symbol: "¥", name: "人民币"),
        Currency(code: "USD", symbol: "$", name: "美元"),
        Currency(code: "EUR", symbol: "€", name: "欧元"),
        Currency(code: "GBP", symbol: "£", name: "英镑"),
        Currency(code: "JPY", symbol: "¥", name: "日元"),
        Currency(code: "HKD", symbol: "HK$", name: "港币"),
        Currency(code: "KRW", symbol: "₩", name: "韩元"),
        Currency(code: "AUD", symbol: "A$", name: "澳元")
    ]
    
    init() {
        self.currencies = CurrencyManager.defaultCurrencies
        
        // 尝试加载保存的货币选择
        if let savedData = UserDefaults.standard.data(forKey: currencySaveKey),
           let savedCurrency = try? JSONDecoder().decode(Currency.self, from: savedData) {
            self.selectedCurrency = savedCurrency
        } else {
            // 默认使用人民币
            self.selectedCurrency = CurrencyManager.defaultCurrencies[0]
        }
    }
    
    /// 保存当前选择的货币到 UserDefaults
    func saveSelectedCurrency() {
        if let encoded = try? JSONEncoder().encode(selectedCurrency) {
            UserDefaults.standard.set(encoded, forKey: currencySaveKey)
        }
    }
    
    /// 格式化金额显示
    /// - Parameter amount: 要格式化的金额
    /// - Returns: 带有货币符号的格式化字符串
    func formatAmount(_ amount: Double) -> String {
        // 处理无效值
        guard amount.isFinite && !amount.isNaN else {
            return selectedCurrency.symbol + "0.00"
        }
        
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
    
    /// 格式化金额用于无障碍阅读
    /// - Parameter amount: 要格式化的金额
    /// - Returns: 完整的货币名称和金额，适合语音朗读
    func formatAmountForAccessibility(_ amount: Double) -> String {
        guard amount.isFinite && !amount.isNaN else {
            return "\(selectedCurrency.name) 0元"
        }
        return "\(selectedCurrency.name) \(String(format: "%.2f", amount))元"
    }
}