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
        
        return principal > 0 && rate > 0 && years > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("投资信息")) {
                    HStack {
                        Text("\(currencyManager.selectedCurrency.symbol)")
                        TextField("本金", text: $principal)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        TextField("年利率", text: $rate)
                            .keyboardType(.decimalPad)
                        Text("%")
                    }
                    
                    HStack {
                        TextField("投资年限", text: $years)
                            .keyboardType(.numberPad)
                        Text("年")
                    }
                    
                    Picker("复利频率", selection: $selectedFrequency) {
                        ForEach(CompoundFrequency.allCases) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                }
                
                Section {
                    Button("计算复利收益") {
                        calculateCompoundInterest()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!isFormValid)
                }
                
                if let result = calculationResult {
                    Section(header: Text("计算结果")) {
                        ResultRow(title: "本金", value: result.principal)
                        ResultRow(title: "总收益", value: result.finalAmount)
                        ResultRow(title: "利息收益", value: result.totalInterest)
                        ResultRow(title: "收益率", value: result.totalInterest / result.principal * 100, isPercentage: true)
                    }
                    
                    Section(header: Text("收益趋势")) {
                        ChartView(data: result.yearlyData)
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
        }
    }
    
    private func calculateCompoundInterest() {
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
        
        calculationResult = result
        historyManager.addToHistory(result)
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
        }
    }
}

#Preview {
    CalculatorView()
        .environmentObject(HistoryManager())
        .environmentObject(CurrencyManager())
}