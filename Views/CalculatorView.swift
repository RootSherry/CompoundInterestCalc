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
    @State private var selectedFrequency: CompoundFrequency = .annually
    @State private var showingResult = false
    @State private var calculationResult: CalculationResult?
    @State private var validationError: String?
    @State private var showValidationError = false
    
    private var formattedPrincipal: Double? {
        return Double(principal.replacingOccurrences(of: ",", with: ""))
    }
    
    private var formattedRate: Double? {
        return Double(rate)
    }
    
    private var formattedYears: Int? {
        return Int(years)
    }
    
    private var isFormValid: Bool {
        guard let principal = formattedPrincipal,
              let rate = formattedRate,
              let years = formattedYears
        else { return false }
        
        return principal > 0 && rate >= 0 && rate <= CompoundInterestCalculator.maxRate && years > 0 && years <= CompoundInterestCalculator.maxYears
    }
    
    /// 验证状态提示
    private var validationHint: String? {
        if let p = formattedPrincipal, p <= 0 {
            return "本金必须大于0"
        }
        if let r = formattedRate {
            if r < 0 {
                return "年利率不能为负数"
            }
            if r > CompoundInterestCalculator.maxRate {
                return "年利率不能超过100%"
            }
        }
        if let y = formattedYears {
            if y <= 0 {
                return "投资年限必须大于0"
            }
            if y > CompoundInterestCalculator.maxYears {
                return "投资年限不能超过100年"
            }
        }
        return nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("投资信息")) {
                    HStack {
                        Text("\(currencyManager.selectedCurrency.symbol)")
                            .foregroundColor(.secondary)
                        TextField("本金", text: $principal)
                            .keyboardType(.decimalPad)
                            .accessibilityLabel("本金输入框")
                            .accessibilityHint("输入投资的初始金额")
                    }
                    .accessibilityElement(children: .combine)
                    
                    HStack {
                        TextField("年利率", text: $rate)
                            .keyboardType(.decimalPad)
                            .accessibilityLabel("年利率输入框")
                            .accessibilityHint("输入预期的年化利率，例如输入5表示5%")
                        Text("%")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    
                    HStack {
                        TextField("投资年限", text: $years)
                            .keyboardType(.numberPad)
                            .accessibilityLabel("投资年限输入框")
                            .accessibilityHint("输入投资的年数，最长100年")
                        Text("年")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    
                    Picker("复利频率", selection: $selectedFrequency) {
                        ForEach(CompoundFrequency.allCases) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                    .accessibilityLabel("复利频率选择")
                    .accessibilityHint(selectedFrequency.accessibilityDescription)
                }
                
                // 显示验证提示
                if let hint = validationHint, !principal.isEmpty || !rate.isEmpty || !years.isEmpty {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(hint)
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("验证提示：\(hint)")
                    }
                }
                
                Section {
                    Button(action: calculateCompoundInterest) {
                        HStack {
                            Spacer()
                            Image(systemName: "calculator")
                            Text("计算复利收益")
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid)
                    .accessibilityLabel("计算复利收益按钮")
                    .accessibilityHint(isFormValid ? "点击计算复利结果" : "请先填写完整的投资信息")
                }
                
                if let result = calculationResult {
                    Section(header: Text("计算结果")) {
                        ResultRow(title: "本金", value: result.principal)
                        ResultRow(title: "总收益", value: result.finalAmount)
                        ResultRow(title: "利息收益", value: result.totalInterest)
                        ResultRow(title: "收益率", value: result.returnPercentage, isPercentage: true)
                    }
                    .accessibilityElement(children: .contain)
                    
                    Section(header: Text("收益趋势")) {
                        ChartView(data: result.yearlyData)
                            .frame(height: 250)
                            .accessibilityLabel("收益趋势图表")
                            .accessibilityHint("显示每年投资金额的增长趋势")
                    }
                    
                    // 添加重置按钮
                    Section {
                        Button(action: resetForm) {
                            HStack {
                                Spacer()
                                Image(systemName: "arrow.counterclockwise")
                                Text("重新计算")
                                Spacer()
                            }
                        }
                        .foregroundColor(.blue)
                        .accessibilityLabel("重新计算按钮")
                        .accessibilityHint("清除当前结果，重新输入")
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
            .alert("输入错误", isPresented: $showValidationError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(validationError ?? "请检查输入")
            }
        }
    }
    
    private func calculateCompoundInterest() {
        // 验证输入
        do {
            try CompoundInterestCalculator.validateInputs(
                principal: formattedPrincipal,
                rate: formattedRate,
                years: formattedYears
            )
        } catch {
            validationError = error.localizedDescription
            showValidationError = true
            triggerHapticFeedback(.error)
            return
        }
        
        guard let principal = formattedPrincipal,
              let rate = formattedRate,
              let years = formattedYears
        else { return }
        
        let result = CompoundInterestCalculator.calculate(
            principal: principal,
            rate: rate,
            years: years,
            frequency: selectedFrequency
        )
        
        // 触发成功触觉反馈
        triggerHapticFeedback(.success)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            calculationResult = result
        }
        historyManager.addToHistory(result)
    }
    
    private func resetForm() {
        triggerHapticFeedback(.light)
        withAnimation(.easeInOut(duration: 0.3)) {
            calculationResult = nil
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// 触发触觉反馈
    private func triggerHapticFeedback(_ type: HapticFeedbackType) {
        switch type {
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    private enum HapticFeedbackType {
        case success
        case error
        case light
    }
}

struct ResultRow: View {
    @EnvironmentObject private var currencyManager: CurrencyManager
    var title: String
    var value: Double
    var isPercentage: Bool = false
    
    /// 安全处理数值，防止 NaN 或无限值
    private var safeValue: Double {
        if value.isNaN || !value.isFinite {
            return 0.0
        }
        return value
    }
    
    /// 格式化后的显示值
    private var displayValue: String {
        if isPercentage {
            return String(format: "%.2f%%", safeValue)
        } else {
            return currencyManager.formatAmount(safeValue)
        }
    }
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(displayValue)
                .fontWeight(.bold)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(displayValue)")
    }
}

struct ChartView: View {
    @EnvironmentObject private var currencyManager: CurrencyManager
    var data: [CalculationResult.YearlyData]
    
    /// 过滤无效数据点
    private var validData: [CalculationResult.YearlyData] {
        return data.filter { 
            $0.amount.isFinite && $0.amount >= 0 && $0.year > 0 
        }
    }
    
    /// 生成图表的无障碍描述
    private var chartAccessibilityDescription: String {
        guard !validData.isEmpty else { return "无数据" }
        let firstYear = validData.first!
        let lastYear = validData.last!
        return "从第1年的\(currencyManager.formatAmount(firstYear.amount))增长到第\(lastYear.year)年的\(currencyManager.formatAmount(lastYear.amount))"
    }
    
    var body: some View {
        if validData.isEmpty {
            Text("无数据可显示")
                .frame(height: 250)
                .frame(maxWidth: .infinity)
                .foregroundColor(.secondary)
                .accessibilityLabel("图表无数据可显示")
        } else {
            Chart {
                ForEach(validData) { item in
                    LineMark(
                        x: .value("年", item.year),
                        y: .value("金额", max(0.01, item.amount))
                    )
                    .foregroundStyle(Color.blue)
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("年", item.year),
                        y: .value("金额", max(0.01, item.amount))
                    )
                    .foregroundStyle(Color.blue)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    if let year = value.as(Int.self), year > 0 {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("\(year)年")
                        }
                    }
                }
            }
            .frame(minHeight: 250)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("收益趋势图表")
            .accessibilityValue(chartAccessibilityDescription)
        }
    }
}

#Preview {
    CalculatorView()
        .environmentObject(HistoryManager())
        .environmentObject(CurrencyManager())
}