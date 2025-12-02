//
//  CurrencyManagerTests.swift
//  复利计算器Tests
//
//  Created by ROOT. on 2025/3/20.
//

import XCTest
@testable import CompoundInterestCalc

final class CurrencyManagerTests: XCTestCase {
    
    var currencyManager: CurrencyManager!
    
    override func setUp() {
        super.setUp()
        currencyManager = CurrencyManager()
    }
    
    override func tearDown() {
        currencyManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testDefaultCurrencyIsCNY() {
        // 如果没有保存的货币选择，默认应该是人民币
        let freshManager = CurrencyManager()
        // 注意：这个测试可能会受到 UserDefaults 中保存值的影响
        XCTAssertEqual(freshManager.currencies.first?.code, "CNY")
    }
    
    func testDefaultCurrenciesCount() {
        XCTAssertEqual(currencyManager.currencies.count, 8)
    }
    
    func testDefaultCurrenciesContainsExpectedCodes() {
        let codes = currencyManager.currencies.map { $0.code }
        XCTAssertTrue(codes.contains("CNY"))
        XCTAssertTrue(codes.contains("USD"))
        XCTAssertTrue(codes.contains("EUR"))
        XCTAssertTrue(codes.contains("GBP"))
        XCTAssertTrue(codes.contains("JPY"))
        XCTAssertTrue(codes.contains("HKD"))
        XCTAssertTrue(codes.contains("KRW"))
        XCTAssertTrue(codes.contains("AUD"))
    }
    
    // MARK: - Format Amount Tests
    
    func testFormatAmountWithCNY() {
        // 选择人民币
        if let cny = currencyManager.currencies.first(where: { $0.code == "CNY" }) {
            currencyManager.selectedCurrency = cny
        }
        
        let formatted = currencyManager.formatAmount(1000.50)
        XCTAssertTrue(formatted.contains("¥"))
        XCTAssertTrue(formatted.contains("1,000.50"))
    }
    
    func testFormatAmountWithUSD() {
        // 选择美元
        if let usd = currencyManager.currencies.first(where: { $0.code == "USD" }) {
            currencyManager.selectedCurrency = usd
        }
        
        let formatted = currencyManager.formatAmount(1000.50)
        XCTAssertTrue(formatted.contains("$"))
        XCTAssertTrue(formatted.contains("1,000.50"))
    }
    
    func testFormatAmountWithLargeNumber() {
        let formatted = currencyManager.formatAmount(1234567.89)
        XCTAssertTrue(formatted.contains("1,234,567.89"))
    }
    
    func testFormatAmountWithSmallNumber() {
        let formatted = currencyManager.formatAmount(0.01)
        XCTAssertTrue(formatted.contains("0.01"))
    }
    
    func testFormatAmountWithZero() {
        let formatted = currencyManager.formatAmount(0)
        XCTAssertTrue(formatted.contains("0.00"))
    }
    
    func testFormatAmountWithNaN() {
        let formatted = currencyManager.formatAmount(Double.nan)
        XCTAssertTrue(formatted.contains("0.00"))
    }
    
    func testFormatAmountWithInfinity() {
        let formatted = currencyManager.formatAmount(Double.infinity)
        XCTAssertTrue(formatted.contains("0.00"))
    }
    
    // MARK: - Accessibility Tests
    
    func testFormatAmountForAccessibility() {
        if let cny = currencyManager.currencies.first(where: { $0.code == "CNY" }) {
            currencyManager.selectedCurrency = cny
        }
        
        let accessible = currencyManager.formatAmountForAccessibility(1000.50)
        XCTAssertTrue(accessible.contains("人民币"))
        XCTAssertTrue(accessible.contains("1000.50"))
    }
    
    func testFormatAmountForAccessibilityWithInvalidValue() {
        let accessible = currencyManager.formatAmountForAccessibility(Double.nan)
        XCTAssertTrue(accessible.contains("0"))
    }
    
    // MARK: - Currency Equality Tests
    
    func testCurrencyEquality() {
        let currency1 = Currency(code: "USD", symbol: "$", name: "美元")
        let currency2 = Currency(code: "USD", symbol: "$", name: "美元")
        let currency3 = Currency(code: "EUR", symbol: "€", name: "欧元")
        
        XCTAssertEqual(currency1, currency2)
        XCTAssertNotEqual(currency1, currency3)
    }
    
    func testCurrencyHashable() {
        let currency1 = Currency(code: "USD", symbol: "$", name: "美元")
        let currency2 = Currency(code: "USD", symbol: "$", name: "美元")
        
        var currencySet: Set<Currency> = []
        currencySet.insert(currency1)
        currencySet.insert(currency2)
        
        // 相同 code 的货币应该被视为相同
        XCTAssertEqual(currencySet.count, 1)
    }
}
