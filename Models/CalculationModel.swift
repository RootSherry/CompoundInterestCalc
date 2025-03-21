//
//  CalculationModel.swift
//  复利计算器
//
//  Created by ROOT. on 2025/3/20.
//

import Foundation

// 复利频率枚举
enum CompoundFrequency: String, CaseIterable, Identifiable {
    case annually = "年"
    case quarterly = "季度"
    case monthly = "月"
    case daily = "日"
    
    var id: String { self.rawValue }
    
    var timesPerYear: Int {
        switch self {
        case .annually: return 1
        case .quarterly: return 4
        case .monthly: return 12
        case .daily: return 365
        }
    }
}

// 计算结果模型
struct CalculationResult: Identifiable, Codable {
    var id = UUID()
    var principal: Double
    var rate: Double
    var years: Int
    var frequency: String
    var finalAmount: Double
    var totalInterest: Double
    var date: Date
    var note: String
    
    // 用于图表显示的年度数据
    var yearlyData: [YearlyData]
    
    struct YearlyData: Identifiable, Codable {
        var id = UUID()
        var year: Int
        var amount: Double
    }
}

// 复利计算逻辑
class CompoundInterestCalculator {
    static func calculate(
        principal: Double,
        rate: Double,
        years: Int,
        frequency: CompoundFrequency
    ) -> CalculationResult {
        let rateDecimal = rate / 100
        let n = Double(frequency.timesPerYear)
        
        var yearlyData: [CalculationResult.YearlyData] = []
        var currentAmount = principal
        
        // 防止计算超出范围
        let maxYears = min(years, 100) // 限制最大年限为100年
        
        for year in 1...maxYears {
            // 安全计算复利，防止溢出
            if n > 0 && rateDecimal > -1 { // 防止除数为0或负数导致无意义的计算
                let exponent = n * Double(year)
                // 使用 Swift 内置函数而不是直接使用 pow 可以避免一些溢出问题
                let base = 1 + (rateDecimal / n)
                // pow 函数在某些输入下可能产生非常大的值或 NaN
                // 添加安全检查
                let powResult = pow(base, exponent)
                if powResult.isFinite && !powResult.isNaN {
                    currentAmount = principal * powResult
                } else {
                    // 如果结果不是有限值，则使用一个大但有限的值
                    currentAmount = principal * Double.greatestFiniteMagnitude / 1_000_000
                }
            } else {
                // 如果频率为0或利率异常，使用简单的计算方式
                currentAmount = principal * (1 + rateDecimal * Double(year))
            }
            
            // 防止结果为负或无限
            currentAmount = min(max(0.0, currentAmount), Double.greatestFiniteMagnitude / 1_000_000)
            
            yearlyData.append(.init(year: year, amount: currentAmount))
        }
        
        var finalAmount = principal
        if n > 0 && rateDecimal > -1 {
            let exponent = n * Double(maxYears)
            let base = 1 + (rateDecimal / n)
            let powResult = pow(base, exponent)
            if powResult.isFinite && !powResult.isNaN {
                finalAmount = principal * powResult
            } else {
                finalAmount = principal * Double.greatestFiniteMagnitude / 1_000_000
            }
        } else {
            finalAmount = principal * (1 + rateDecimal * Double(maxYears))
        }
        
        // 防止结果为负或无限
        finalAmount = min(max(0.0, finalAmount), Double.greatestFiniteMagnitude / 1_000_000)
        let interest = max(0.0, finalAmount - principal)
        
        return CalculationResult(
            principal: principal,
            rate: rate,
            years: maxYears,
            frequency: frequency.rawValue,
            finalAmount: finalAmount,
            totalInterest: interest,
            date: Date(),
            note: "",
            yearlyData: yearlyData
        )
    }
}