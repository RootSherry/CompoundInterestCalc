//
//  CalculatorView.swift
//  复利计算器
//
//  Created by ROOT. on 2025/3/20.
//

import SwiftUI
import Charts

struct CalculatorView: View {
    @EnvironmentObject private var historyManager: HistoryManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    
    @State private var principal: String = ""
    @State private var rate: String = ""
    @State private var years: String = ""
    @State private var monthlyContribution: String = ""
    @State private var inflationRate: String = ""
    @State private var selectedFrequency: CompoundFrequency = .annually
    @State private var investmentType: InvestmentType = .lumpSum
    @State private var showingResult = false
    @State private var calculationResult: CalculationResult?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isCalculating = false
    
    // 目标导向计算状态
    @State private var targetAmount: String = ""
    @State private var targetCalculationType: TargetCalculationType = .timeToReachTarget
    
    // 输入验证状态
    @State private var principalError: String? = nil
    @State private var rateError: String? = nil
    @State private var yearsError: String? = nil
    @State private var monthlyContributionError: String? = nil
    @State private var targetAmountError: String? = nil
    
    private var formattedPrincipal: Double? {
        return Double(principal.replacingOccurrences(of: ",", with: ""))
    }
    
    private var formattedRate: Double? {
        return Double(rate)
    }
    
    private var formattedYears: Int? {
        return Int(years)
    }
    
    private var formattedMonthlyContribution: Double? {
        let value = Double(monthlyContribution.replacingOccurrences(of: ",", with: "")) ?? 0
        return value >= 0 ? value : nil
    }
    
    private var formattedInflationRate: Double? {
        let value = Double(inflationRate) ?? 0
        return value >= 0 ? value : nil
    }
    
    private var formattedTargetAmount: Double? {
        return Double(targetAmount.replacingOccurrences(of: ",", with: ""))
    }
    
    // 实时输入验证
    private func validateInputs() {
        // 验证本金
        if let p = formattedPrincipal {
            principalError = p <= 0 ? "本金必须大于0" : nil
        } else {
            principalError = principal.isEmpty ? nil : "请输入有效的数字"
        }
        
        // 验证利率
        if let r = formattedRate {
            if r < CalculationConstants.minValidRate || r > CalculationConstants.maxValidRate {
                rateError = "年利率必须在\(CalculationConstants.minValidRate)%到\(CalculationConstants.maxValidRate)%之间"
            } else {
                rateError = nil
            }
        } else {
            rateError = rate.isEmpty ? nil : "请输入有效的利率"
        }
        
        // 验证年限
        if let y = formattedYears {
            if y <= 0 || y > CalculationConstants.maxYearsLimit {
                yearsError = "投资年限必须在1到\(CalculationConstants.maxYearsLimit)年之间"
            } else {
                yearsError = nil
            }
        } else {
            yearsError = years.isEmpty ? nil : "请输入有效的年限"
        }
        
        // 验证月投资额
        if !monthlyContribution.isEmpty {
            if formattedMonthlyContribution == nil {
                monthlyContributionError = "请输入有效的月投资额"
            } else {
                monthlyContributionError = nil
            }
        } else {
            monthlyContributionError = nil
        }
        
        // 验证目标金额（仅当选择目标导向时）
        if investmentType == .target {
            if let t = formattedTargetAmount {
                if t <= 0 {
                    targetAmountError = "目标金额必须大于0"
                } else if let p = formattedPrincipal, t <= p {
                    targetAmountError = "目标金额必须大于本金"
                } else {
                    targetAmountError = nil
                }
            } else {
                targetAmountError = targetAmount.isEmpty ? nil : "请输入有效的目标金额"
            }
        } else {
            targetAmountError = nil
        }
    }
    
    private var isFormValid: Bool {
        guard let principal = formattedPrincipal,
              let rate = formattedRate,
              let years = formattedYears
        else { return false }
        
        let baseValidation = principal > 0 && 
               rate >= CalculationConstants.minValidRate && 
               rate <= CalculationConstants.maxValidRate &&
               years > 0 && 
               years <= CalculationConstants.maxYearsLimit &&
               principalError == nil &&
               rateError == nil &&
               yearsError == nil &&
               monthlyContributionError == nil
        
        // 目标导向计算需要额外验证
        if investmentType == .target {
            guard let targetAmount = formattedTargetAmount,
                  targetAmount > principal,
                  targetAmountError == nil else {
                return false
            }
        }
        
        return baseValidation
    }
    
    private var targetCalculationFooter: String {
        switch targetCalculationType {
        case .timeToReachTarget:
            return "计算达到目标金额需要多少年"
        case .monthlyContributionNeeded:
            return "计算每月需要投资多少钱才能达到目标"
        case .initialAmountNeeded:
            return "计算需要多少初始本金才能达到目标"
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 投资类型选择
                Section(header: Text("投资类型")) {
                    Picker("投资类型", selection: $investmentType) {
                        ForEach(InvestmentType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: investmentType) { _ in
                        validateInputs()
                    }
                }
                
                Section(header: Text("投资信息")) {
                    // 本金输入
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(currencyManager.selectedCurrency.symbol)")
                            TextField("本金", text: $principal)
                                .keyboardType(.decimalPad)
                                .onChange(of: principal) { _ in
                                    validateInputs()
                                }
                        }
                        if let error = principalError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // 年利率输入
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            TextField("年利率", text: $rate)
                                .keyboardType(.decimalPad)
                                .onChange(of: rate) { _ in
                                    validateInputs()
                                }
                            Text("%")
                        }
                        if let error = rateError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // 投资年限输入
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            TextField("投资年限", text: $years)
                                .keyboardType(.numberPad)
                                .onChange(of: years) { _ in
                                    validateInputs()
                                }
                            Text("年")
                        }
                        if let error = yearsError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // 复利频率选择
                    Picker("复利频率", selection: $selectedFrequency) {
                        ForEach(CompoundFrequency.allCases) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                }
                
                // 定期投资选项（仅当选择定期投资时显示）
                if investmentType == .regular {
                    Section(header: Text("定期投资"), footer: Text("每月固定投资金额")) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("\(currencyManager.selectedCurrency.symbol)")
                                TextField("月投资额", text: $monthlyContribution)
                                    .keyboardType(.decimalPad)
                                    .onChange(of: monthlyContribution) { _ in
                                        validateInputs()
                                    }
                                Text("/ 月")
                            }
                            if let error = monthlyContributionError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                // 通胀选项
                Section(header: Text("通胀调整"), footer: Text("考虑通胀对实际购买力的影响")) {
                    HStack {
                        TextField("通胀率（可选）", text: $inflationRate)
                            .keyboardType(.decimalPad)
                        Text("%")
                    }
                }
                
                // 目标导向计算选项
                if investmentType == .target {
                    Section(header: Text("目标设定"), footer: targetCalculationFooter) {
                        // 目标金额输入
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("\(currencyManager.selectedCurrency.symbol)")
                                TextField("目标金额", text: $targetAmount)
                                    .keyboardType(.decimalPad)
                                    .onChange(of: targetAmount) { _ in
                                        validateInputs()
                                    }
                            }
                            if let error = targetAmountError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // 计算类型选择
                        Picker("计算类型", selection: $targetCalculationType) {
                            ForEach(TargetCalculationType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: targetCalculationType) { _ in
                            validateInputs()
                        }
                        
                        // 根据计算类型显示不同的输入字段
                        if targetCalculationType == .monthlyContributionNeeded && monthlyContribution.isEmpty {
                            Text("将计算达到目标金额需要的月投资额")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if targetCalculationType == .initialAmountNeeded {
                            Text("将计算达到目标金额需要的初始本金")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if targetCalculationType == .timeToReachTarget {
                            Text("将计算达到目标金额需要的时间")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 计算按钮
                Section {
                    Button(action: {
                        calculateCompoundInterest()
                    }) {
                        HStack {
                            if isCalculating {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .padding(.trailing, 8)
                            }
                            Text(isCalculating ? "计算中..." : "计算复利收益")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(!isFormValid || isCalculating)
                }
                
                // 计算结果显示
                if let result = calculationResult {
                    Section(header: Text("计算结果")) {
                        // 显示不同类型的计算结果
                        if result.investmentType == .target {
                            // 目标导向计算结果
                            if let targetAmount = result.targetAmount {
                                ResultRow(title: "目标金额", value: targetAmount)
                            }
                            
                            if let calculationType = result.calculationType {
                                switch calculationType {
                                case .timeToReachTarget:
                                    if let years = result.yearsToTarget {
                                        HStack {
                                            Text("所需时间")
                                            Spacer()
                                            Text(String(format: "%.1f年", years))
                                                .fontWeight(.bold)
                                        }
                                    }
                                    
                                case .monthlyContributionNeeded:
                                    if let monthly = result.monthlyNeeded {
                                        ResultRow(title: "每月投资额", value: monthly)
                                    }
                                    
                                case .initialAmountNeeded:
                                    if let principal = result.principalNeeded {
                                        ResultRow(title: "所需本金", value: principal)
                                    }
                                }
                            }
                        } else {
                            // 传统计算结果
                            ResultRow(title: "本金", value: result.principal)
                            if let monthlyContrib = result.monthlyContribution, monthlyContrib > 0 {
                                ResultRow(title: "总投资额", value: result.principal + (monthlyContrib * 12 * Double(result.years)))
                            }
                            ResultRow(title: "最终金额", value: result.finalAmount)
                            ResultRow(title: "利息收益", value: result.totalInterest)
                            
                            let totalInvestment = result.principal + ((result.monthlyContribution ?? 0) * 12 * Double(result.years))
                            ResultRow(title: "收益率", value: (result.finalAmount - totalInvestment) / totalInvestment * 100, isPercentage: true)
                            
                            // 实际收益率（考虑通胀）
                            if let inflationRate = result.inflationRate, inflationRate > 0 {
                                ResultRow(title: "实际收益率", value: result.realReturnRate, isPercentage: true)
                            }
                        }
                    }
                    
                    Section(header: Text("收益趋势")) {
                        ChartView(data: result.optimizedYearlyData)
                            .frame(height: 250)
                    }
                }
            }
            .navigationTitle("复利计算器")
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("完成") {
                        hideKeyboard()
                    }
                }
            }
            .alert("计算错误", isPresented: $showingError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func calculateCompoundInterest() {
        guard let principal = formattedPrincipal,
              let rate = formattedRate,
              let years = formattedYears
        else { return }
        
        // 开始计算，显示加载状态
        isCalculating = true
        
        // 异步执行计算以避免界面卡顿
        DispatchQueue.global(qos: .userInitiated).async {
            let monthlyContrib = self.formattedMonthlyContribution ?? 0
            let inflation = self.formattedInflationRate ?? 0
            
            let result: Result<CalculationResult, CalculationError>
            
            // 根据投资类型选择不同的计算方法
            switch self.investmentType {
            case .lumpSum, .regular:
                result = CompoundInterestCalculator.calculate(
                    principal: principal,
                    rate: rate,
                    years: years,
                    frequency: self.selectedFrequency,
                    monthlyContribution: monthlyContrib,
                    inflationRate: inflation
                )
                
            case .target:
                guard let targetAmount = self.formattedTargetAmount else {
                    DispatchQueue.main.async {
                        self.isCalculating = false
                        self.errorMessage = "请输入目标金额"
                        self.showingError = true
                    }
                    return
                }
                
                switch self.targetCalculationType {
                case .timeToReachTarget:
                    result = CompoundInterestCalculator.calculateTimeToTarget(
                        targetAmount: targetAmount,
                        principal: principal,
                        rate: rate,
                        frequency: self.selectedFrequency,
                        monthlyContribution: monthlyContrib
                    )
                    
                case .monthlyContributionNeeded:
                    result = CompoundInterestCalculator.calculateMonthlyContributionForTarget(
                        targetAmount: targetAmount,
                        principal: principal,
                        rate: rate,
                        years: years,
                        frequency: self.selectedFrequency
                    )
                    
                case .initialAmountNeeded:
                    result = CompoundInterestCalculator.calculatePrincipalForTarget(
                        targetAmount: targetAmount,
                        rate: rate,
                        years: years,
                        frequency: self.selectedFrequency,
                        monthlyContribution: monthlyContrib
                    )
                }
            }
            
            DispatchQueue.main.async {
                self.isCalculating = false
                
                switch result {
                case .success(let calculationResult):
                    self.calculationResult = calculationResult
                    self.historyManager.addToHistory(calculationResult)
                    self.hideKeyboard()
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showingError = true
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ResultRow: View {
    @EnvironmentObject private var currencyManager: CurrencyManager
    var title: String
    var value: Double
    var isPercentage: Bool = false
    
    // 安全处理数值
    private var safeValue: Double {
        if value.isNaN || !value.isFinite {
            return 0.0
        }
        return value
    }
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if isPercentage {
                Text(String(format: "%.2f%%", safeValue))
                    .fontWeight(.bold)
            } else {
                Text(currencyManager.formatAmount(safeValue))
                    .fontWeight(.bold)
            }
        }
    }
}

struct ChartView: View {
    @EnvironmentObject private var currencyManager: CurrencyManager
    var data: [CalculationResult.YearlyData]
    
    // 过滤无效数据点
    private var validData: [CalculationResult.YearlyData] {
        return data.filter { 
            $0.amount.isFinite && $0.amount >= 0 && $0.year > 0 
        }
    }
    
    var body: some View {
        if validData.isEmpty {
            Text("无数据可显示")
                .frame(height: 250)
                .frame(maxWidth: .infinity)
                .foregroundColor(.secondary)
        } else {
            Chart {
                ForEach(validData) { item in
                    // 主要增长线
                    LineMark(
                        x: .value("年", item.year),
                        y: .value("总金额", max(0.01, item.amount))
                    )
                    .foregroundStyle(Color.blue)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    // 数据点
                    PointMark(
                        x: .value("年", item.year),
                        y: .value("总金额", max(0.01, item.amount))
                    )
                    .foregroundStyle(Color.blue)
                    .symbol(Circle().strokeBorder(lineWidth: 2))
                    
                    // 如果有投资额信息，显示投资线
                    if let contribution = item.contribution, contribution > 0 {
                        LineMark(
                            x: .value("年", item.year),
                            y: .value("投资额", contribution)
                        )
                        .foregroundStyle(Color.green.opacity(0.7))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(currencyManager.formatAmount(doubleValue))
                                .font(.caption)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    if let year = value.as(Int.self), year > 0 {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("\(year)年")
                                .font(.caption)
                        }
                    }
                }
            }
            .frame(minHeight: 250)
            .chartLegend(position: .bottom) {
                HStack {
                    HStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        Text("总金额")
                            .font(.caption)
                    }
                    
                    if validData.contains(where: { $0.contribution != nil && $0.contribution! > 0 }) {
                        HStack {
                            Rectangle()
                                .fill(Color.green.opacity(0.7))
                                .frame(width: 12, height: 2)
                            Text("累计投资")
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CalculatorView()
        .environmentObject(HistoryManager())
        .environmentObject(CurrencyManager())
}