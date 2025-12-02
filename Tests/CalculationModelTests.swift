//
//  CalculationModelTests.swift
//  复利计算器Tests
//
//  Created by ROOT. on 2025/3/20.
//

import XCTest
@testable import CompoundInterestCalc

final class CalculationModelTests: XCTestCase {
    
    // MARK: - CompoundFrequency Tests
    
    func testCompoundFrequencyTimesPerYear() {
        XCTAssertEqual(CompoundFrequency.annually.timesPerYear, 1)
        XCTAssertEqual(CompoundFrequency.quarterly.timesPerYear, 4)
        XCTAssertEqual(CompoundFrequency.monthly.timesPerYear, 12)
        XCTAssertEqual(CompoundFrequency.daily.timesPerYear, 365)
    }
    
    func testCompoundFrequencyRawValues() {
        XCTAssertEqual(CompoundFrequency.annually.rawValue, "年")
        XCTAssertEqual(CompoundFrequency.quarterly.rawValue, "季度")
        XCTAssertEqual(CompoundFrequency.monthly.rawValue, "月")
        XCTAssertEqual(CompoundFrequency.daily.rawValue, "日")
    }
    
    // MARK: - Input Validation Tests
    
    func testValidInputs() {
        XCTAssertNoThrow(try CompoundInterestCalculator.validateInputs(
            principal: 10000,
            rate: 5,
            years: 10
        ))
    }
    
    func testInvalidPrincipal() {
        XCTAssertThrowsError(try CompoundInterestCalculator.validateInputs(
            principal: nil,
            rate: 5,
            years: 10
        ))
        
        XCTAssertThrowsError(try CompoundInterestCalculator.validateInputs(
            principal: 0,
            rate: 5,
            years: 10
        ))
        
        XCTAssertThrowsError(try CompoundInterestCalculator.validateInputs(
            principal: -1000,
            rate: 5,
            years: 10
        ))
    }
    
    func testInvalidRate() {
        XCTAssertThrowsError(try CompoundInterestCalculator.validateInputs(
            principal: 10000,
            rate: nil,
            years: 10
        ))
        
        XCTAssertThrowsError(try CompoundInterestCalculator.validateInputs(
            principal: 10000,
            rate: -5,
            years: 10
        ))
        
        XCTAssertThrowsError(try CompoundInterestCalculator.validateInputs(
            principal: 10000,
            rate: 150,
            years: 10
        ))
    }
    
    func testInvalidYears() {
        XCTAssertThrowsError(try CompoundInterestCalculator.validateInputs(
            principal: 10000,
            rate: 5,
            years: nil
        ))
        
        XCTAssertThrowsError(try CompoundInterestCalculator.validateInputs(
            principal: 10000,
            rate: 5,
            years: 0
        ))
        
        XCTAssertThrowsError(try CompoundInterestCalculator.validateInputs(
            principal: 10000,
            rate: 5,
            years: 150
        ))
    }
    
    // MARK: - Calculation Tests
    
    func testBasicCalculation() {
        // 本金 10000，年利率 5%，1年，年复利
        // 期望: 10000 * (1 + 0.05)^1 = 10500
        let result = CompoundInterestCalculator.calculate(
            principal: 10000,
            rate: 5,
            years: 1,
            frequency: .annually
        )
        
        XCTAssertEqual(result.principal, 10000)
        XCTAssertEqual(result.rate, 5)
        XCTAssertEqual(result.years, 1)
        XCTAssertEqual(result.finalAmount, 10500, accuracy: 0.01)
        XCTAssertEqual(result.totalInterest, 500, accuracy: 0.01)
    }
    
    func testMonthlyCompounding() {
        // 本金 10000，年利率 12%，1年，月复利
        // 期望: 10000 * (1 + 0.12/12)^12 = 10000 * 1.01^12 ≈ 11268.25
        let result = CompoundInterestCalculator.calculate(
            principal: 10000,
            rate: 12,
            years: 1,
            frequency: .monthly
        )
        
        XCTAssertEqual(result.finalAmount, 11268.25, accuracy: 1.0)
    }
    
    func testQuarterlyCompounding() {
        // 本金 10000，年利率 8%，1年，季度复利
        // 期望: 10000 * (1 + 0.08/4)^4 = 10000 * 1.02^4 ≈ 10824.32
        let result = CompoundInterestCalculator.calculate(
            principal: 10000,
            rate: 8,
            years: 1,
            frequency: .quarterly
        )
        
        XCTAssertEqual(result.finalAmount, 10824.32, accuracy: 1.0)
    }
    
    func testDailyCompounding() {
        // 本金 10000，年利率 5%，1年，日复利
        // 期望: 10000 * (1 + 0.05/365)^365 ≈ 10512.67
        let result = CompoundInterestCalculator.calculate(
            principal: 10000,
            rate: 5,
            years: 1,
            frequency: .daily
        )
        
        XCTAssertEqual(result.finalAmount, 10512.67, accuracy: 1.0)
    }
    
    func testMultiYearCalculation() {
        // 本金 10000，年利率 10%，5年，年复利
        // 期望: 10000 * (1.1)^5 = 16105.10
        let result = CompoundInterestCalculator.calculate(
            principal: 10000,
            rate: 10,
            years: 5,
            frequency: .annually
        )
        
        XCTAssertEqual(result.finalAmount, 16105.10, accuracy: 1.0)
        XCTAssertEqual(result.yearlyData.count, 5)
    }
    
    func testYearlyDataProgression() {
        let result = CompoundInterestCalculator.calculate(
            principal: 10000,
            rate: 10,
            years: 3,
            frequency: .annually
        )
        
        XCTAssertEqual(result.yearlyData.count, 3)
        XCTAssertEqual(result.yearlyData[0].year, 1)
        XCTAssertEqual(result.yearlyData[1].year, 2)
        XCTAssertEqual(result.yearlyData[2].year, 3)
        
        // 确保金额逐年递增
        XCTAssertLessThan(result.yearlyData[0].amount, result.yearlyData[1].amount)
        XCTAssertLessThan(result.yearlyData[1].amount, result.yearlyData[2].amount)
    }
    
    func testZeroRate() {
        // 本金 10000，年利率 0%，5年
        // 期望: 本金不变 = 10000
        let result = CompoundInterestCalculator.calculate(
            principal: 10000,
            rate: 0,
            years: 5,
            frequency: .annually
        )
        
        XCTAssertEqual(result.finalAmount, 10000, accuracy: 0.01)
        XCTAssertEqual(result.totalInterest, 0, accuracy: 0.01)
    }
    
    func testMaxYearsLimit() {
        // 测试超过最大年限的情况
        let result = CompoundInterestCalculator.calculate(
            principal: 10000,
            rate: 5,
            years: 150,
            frequency: .annually
        )
        
        // 应该被限制在 100 年
        XCTAssertEqual(result.years, 100)
        XCTAssertEqual(result.yearlyData.count, 100)
    }
    
    // MARK: - CalculationResult Tests
    
    func testReturnPercentage() {
        let result = CompoundInterestCalculator.calculate(
            principal: 10000,
            rate: 10,
            years: 1,
            frequency: .annually
        )
        
        // 收益率应该是 5% (利息 1000 / 本金 10000)
        XCTAssertEqual(result.returnPercentage, 10, accuracy: 0.1)
    }
    
    func testFormattedReturnPercentage() {
        let result = CompoundInterestCalculator.calculate(
            principal: 10000,
            rate: 10,
            years: 1,
            frequency: .annually
        )
        
        XCTAssertTrue(result.formattedReturnPercentage.contains("%"))
    }
}
