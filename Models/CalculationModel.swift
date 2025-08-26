//
//  CalculationModel.swift
//  复利计算器
//
//  Created by ROOT. on 2025/3/20.
//

import Foundation

// 计算常量
struct CalculationConstants {
    static let maxYearsLimit = 100
    static let maxSafeAmount = Double.greatestFiniteMagnitude / 1_000_000
    static let minValidRate = -99.99 // 最低利率限制
    static let maxValidRate = 999.99 // 最高利率限制
    static let maxDataPointsForChart = 50 // 图表最大数据点
}

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
    
    var displayName: String {
        switch self {
        case .annually: return "按年复利"
        case .quarterly: return "按季度复利"
        case .monthly: return "按月复利"
        case .daily: return "按日复利"
        }
    }
}

// 投资类型枚举
enum InvestmentType: String, CaseIterable, Codable {
    case lumpSum = "一次性投资"
    case regular = "定期投资"
    case target = "目标导向"
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
    
    // 新增字段 - 向下兼容
    var investmentType: InvestmentType?
    var monthlyContribution: Double?
    var inflationRate: Double?
    var realReturn: Double? // 实际收益率（扣除通胀）
    
    // 用于图表显示的年度数据
    var yearlyData: [YearlyData]
    
    struct YearlyData: Identifiable, Codable {
        var id = UUID()
        var year: Int
        var amount: Double
        var contribution: Double? // 当年投入金额
        var interest: Double? // 当年利息收益
    }
    
    // 计算实际收益率（考虑通胀）
    var realReturnRate: Double {
        guard let inflationRate = inflationRate, inflationRate > 0 else { return rate }
        return ((1 + rate / 100) / (1 + inflationRate / 100) - 1) * 100
    }
    
    // 获取优化后的图表数据（数据采样）
    var optimizedYearlyData: [YearlyData] {
        guard yearlyData.count > CalculationConstants.maxDataPointsForChart else {
            return yearlyData
        }
        
        let step = yearlyData.count / CalculationConstants.maxDataPointsForChart
        var sampledData: [YearlyData] = []
        
        for i in stride(from: 0, to: yearlyData.count, by: step) {
            sampledData.append(yearlyData[i])
        }
        
        // 确保包含最后一个数据点
        if let lastData = yearlyData.last, sampledData.last?.year != lastData.year {
            sampledData.append(lastData)
        }
        
        return sampledData
    }
}

// 输入验证错误类型
enum CalculationError: Error, LocalizedError {
    case invalidPrincipal
    case invalidRate
    case invalidYears
    case invalidMonthlyContribution
    case calculationOverflow
    
    var errorDescription: String? {
        switch self {
        case .invalidPrincipal:
            return "本金必须大于0"
        case .invalidRate:
            return "年利率必须在\(CalculationConstants.minValidRate)%到\(CalculationConstants.maxValidRate)%之间"
        case .invalidYears:
            return "投资年限必须在1到\(CalculationConstants.maxYearsLimit)年之间"
        case .invalidMonthlyContribution:
            return "月投资额必须大于或等于0"
        case .calculationOverflow:
            return "计算结果超出范围，请调整输入参数"
        }
    }
}

// 复利计算逻辑
class CompoundInterestCalculator {
    
    // 输入验证
    static func validateInputs(
        principal: Double,
        rate: Double,
        years: Int,
        monthlyContribution: Double = 0
    ) throws {
        guard principal > 0 else { throw CalculationError.invalidPrincipal }
        guard rate >= CalculationConstants.minValidRate && rate <= CalculationConstants.maxValidRate else {
            throw CalculationError.invalidRate
        }
        guard years > 0 && years <= CalculationConstants.maxYearsLimit else {
            throw CalculationError.invalidYears
        }
        guard monthlyContribution >= 0 else { throw CalculationError.invalidMonthlyContribution }
    }
    
    // 使用Decimal进行高精度计算
    private static func calculateWithDecimal(
        principal: Decimal,
        rate: Decimal,
        years: Int,
        frequency: CompoundFrequency,
        monthlyContribution: Decimal = 0
    ) -> (finalAmount: Decimal, yearlyData: [CalculationResult.YearlyData]) {
        let rateDecimal = rate / 100
        let n = Decimal(frequency.timesPerYear)
        let periodsPerYear = Decimal(12) // 每年12个月
        
        var yearlyData: [CalculationResult.YearlyData] = []
        var currentAmount = principal
        var totalContributions = principal
        
        for year in 1...years {
            let yearlyContribution = monthlyContribution * 12
            
            // 计算复利
            if n > 0 && rateDecimal > -1 {
                let periodsThisYear = n
                let ratePerPeriod = rateDecimal / n
                
                // 分期计算年内复利和定投
                for month in 1...12 {
                    // 添加月投资额
                    if monthlyContribution > 0 {
                        currentAmount += monthlyContribution
                        totalContributions += monthlyContribution
                    }
                    
                    // 计算月复利
                    if frequency == .monthly || frequency == .daily {
                        let monthlyRate = ratePerPeriod
                        currentAmount = currentAmount * (1 + monthlyRate)
                    }
                }
                
                // 年度复利（对于年/季度复利）
                if frequency == .annually {
                    currentAmount = currentAmount * (1 + rateDecimal)
                } else if frequency == .quarterly {
                    let quarterlyRate = rateDecimal / 4
                    currentAmount = currentAmount * pow(1 + quarterlyRate, 4)
                }
                
            } else {
                // 简单利息计算
                currentAmount = principal * (1 + rateDecimal * Decimal(year)) + (yearlyContribution * Decimal(year))
                totalContributions += yearlyContribution
            }
            
            let yearInterest = max(0, currentAmount - totalContributions)
            
            yearlyData.append(.init(
                year: year,
                amount: NSDecimalNumber(decimal: currentAmount).doubleValue,
                contribution: NSDecimalNumber(decimal: yearlyContribution).doubleValue,
                interest: NSDecimalNumber(decimal: yearInterest).doubleValue
            ))
        }
        
        return (currentAmount, yearlyData)
    }
    
    static func calculate(
        principal: Double,
        rate: Double,
        years: Int,
        frequency: CompoundFrequency,
        monthlyContribution: Double = 0,
        inflationRate: Double = 0
    ) -> Result<CalculationResult, CalculationError> {
        // 输入验证
        do {
            try validateInputs(
                principal: principal,
                rate: rate,
                years: years,
                monthlyContribution: monthlyContribution
            )
        } catch let error as CalculationError {
            return .failure(error)
        } catch {
            return .failure(.calculationOverflow)
        }
        
        let maxYears = min(years, CalculationConstants.maxYearsLimit)
        
        // 使用Decimal进行高精度计算
        let principalDecimal = Decimal(principal)
        let rateDecimal = Decimal(rate)
        let monthlyContributionDecimal = Decimal(monthlyContribution)
        
        let (finalAmountDecimal, yearlyData) = calculateWithDecimal(
            principal: principalDecimal,
            rate: rateDecimal,
            years: maxYears,
            frequency: frequency,
            monthlyContribution: monthlyContributionDecimal
        )
        
        let finalAmount = NSDecimalNumber(decimal: finalAmountDecimal).doubleValue
        
        // 安全检查结果
        guard finalAmount.isFinite && !finalAmount.isNaN else {
            return .failure(.calculationOverflow)
        }
        
        let safeFinalAmount = min(max(0.0, finalAmount), CalculationConstants.maxSafeAmount)
        let totalContributions = principal + (monthlyContribution * 12 * Double(maxYears))
        let interest = max(0.0, safeFinalAmount - totalContributions)
        
        let result = CalculationResult(
            principal: principal,
            rate: rate,
            years: maxYears,
            frequency: frequency.rawValue,
            finalAmount: safeFinalAmount,
            totalInterest: interest,
            date: Date(),
            note: "",
            investmentType: monthlyContribution > 0 ? .regular : .lumpSum,
            monthlyContribution: monthlyContribution > 0 ? monthlyContribution : nil,
            inflationRate: inflationRate > 0 ? inflationRate : nil,
            realReturn: inflationRate > 0 ? safeFinalAmount * (1 - inflationRate/100) : nil,
            yearlyData: yearlyData
        )
        
        return .success(result)
    }
    
    // 传统方法保持向后兼容
    static func calculate(
        principal: Double,
        rate: Double,
        years: Int,
        frequency: CompoundFrequency
    ) -> CalculationResult {
        let result = calculate(
            principal: principal,
            rate: rate,
            years: years,
            frequency: frequency,
            monthlyContribution: 0,
            inflationRate: 0
        )
        
        switch result {
        case .success(let calculationResult):
            return calculationResult
        case .failure(_):
            // 降级到原始计算逻辑以保持兼容性
            return legacyCalculate(
                principal: principal,
                rate: rate,
                years: years,
                frequency: frequency
            )
        }
    }
    
    // 保留原始计算逻辑作为后备
    private static func legacyCalculate(
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
        let maxYears = min(years, CalculationConstants.maxYearsLimit)
        
        for year in 1...maxYears {
            // 安全计算复利，防止溢出
            if n > 0 && rateDecimal > -1 { 
                let exponent = n * Double(year)
                let base = 1 + (rateDecimal / n)
                let powResult = pow(base, exponent)
                
                if powResult.isFinite && !powResult.isNaN {
                    currentAmount = principal * powResult
                } else {
                    currentAmount = principal * CalculationConstants.maxSafeAmount
                }
            } else {
                currentAmount = principal * (1 + rateDecimal * Double(year))
            }
            
            // 防止结果为负或无限
            currentAmount = min(max(0.0, currentAmount), CalculationConstants.maxSafeAmount)
            
            yearlyData.append(.init(
                year: year, 
                amount: currentAmount,
                contribution: year == 1 ? principal : 0,
                interest: max(0, currentAmount - principal)
            ))
        }
        
        var finalAmount = principal
        if n > 0 && rateDecimal > -1 {
            let exponent = n * Double(maxYears)
            let base = 1 + (rateDecimal / n)
            let powResult = pow(base, exponent)
            if powResult.isFinite && !powResult.isNaN {
                finalAmount = principal * powResult
            } else {
                finalAmount = principal * CalculationConstants.maxSafeAmount
            }
        } else {
            finalAmount = principal * (1 + rateDecimal * Double(maxYears))
        }
        
        finalAmount = min(max(0.0, finalAmount), CalculationConstants.maxSafeAmount)
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
            investmentType: .lumpSum,
            monthlyContribution: nil,
            inflationRate: nil,
            realReturn: nil,
            yearlyData: yearlyData
        )
    }
}