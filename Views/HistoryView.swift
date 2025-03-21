//
//  HistoryView.swift
//  复利计算器
//
//  Created by ROOT. on 2025/3/20.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var historyManager: HistoryManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    @State private var showingDeleteAlert = false
    @State private var selectedResult: CalculationResult?
    @State private var showingDetailView = false
    
    var body: some View {
        NavigationStack {
            List {
                if historyManager.history.isEmpty {
                    Text("暂无历史记录")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(historyManager.history) { result in
                        HistoryRowView(result: result)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedResult = result
                                showingDetailView = true
                            }
                    }
                    .onDelete { indices in
                        historyManager.deleteRecord(at: indices)
                    }
                }
            }
            .navigationTitle("历史记录")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                        .disabled(historyManager.history.isEmpty)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(historyManager.history.isEmpty)
                }
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    historyManager.clearAllHistory()
                }
            } message: {
                Text("确定要删除所有历史记录吗？")
            }
            .sheet(isPresented: $showingDetailView) {
                if let result = selectedResult {
                    HistoryDetailView(result: result)
                        .environmentObject(currencyManager)
                }
            }
        }
    }
}

struct HistoryRowView: View {
    @EnvironmentObject private var currencyManager: CurrencyManager
    var result: CalculationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("本金: \(currencyManager.formatAmount(result.principal))")
                    .fontWeight(.medium)
                Spacer()
                Text(formattedDate(result.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text("年利率: \(String(format: "%.2f", result.rate))%")
                Spacer()
                Text("频率: \(result.frequency)")
            }
            .foregroundColor(.secondary)
            
            HStack {
                Text("期限: \(result.years)年")
                Spacer()
                Text("最终收益: \(currencyManager.formatAmount(result.finalAmount))")
                    .fontWeight(.bold)
            }
            
            if !result.note.isEmpty {
                Text(result.note)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct HistoryDetailView: View {
    @EnvironmentObject private var currencyManager: CurrencyManager
    @Environment(\.dismiss) private var dismiss
    @State private var note: String
    @State private var isSharePresented: Bool = false
    var result: CalculationResult
    
    init(result: CalculationResult) {
        self.result = result
        self._note = State(initialValue: result.note)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("投资详情")) {
                    DetailRow(title: "本金", value: currencyManager.formatAmount(result.principal))
                    DetailRow(title: "年利率", value: "\(String(format: "%.2f", result.rate))%")
                    DetailRow(title: "投资期限", value: "\(result.years)年")
                    DetailRow(title: "复利频率", value: result.frequency)
                    DetailRow(title: "计算日期", value: formattedDate(result.date))
                }
                
                Section(header: Text("计算结果")) {
                    DetailRow(title: "最终金额", value: currencyManager.formatAmount(result.finalAmount))
                    DetailRow(title: "利息收益", value: currencyManager.formatAmount(result.totalInterest))
                    DetailRow(title: "收益率", value: "\(String(format: "%.2f", result.totalInterest / result.principal * 100))%")
                }
                
                Section(header: Text("收益趋势")) {
                    if result.yearlyData.isEmpty {
                        Text("无数据可显示")
                            .frame(height: 250)
                            .frame(maxWidth: .infinity)
                    } else {
                        ChartView(data: result.yearlyData)
                            .frame(height: 250)
                            .environmentObject(currencyManager)
                    }
                }
                
                Section(header: Text("备注")) {
                    TextEditor(text: $note)
                        .frame(height: 100)
                }
                
                Section {
                    ShareLink(item: generateShareText()) {
                        Text("分享结果")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("详细信息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func generateShareText() -> String {
        return """
        复利计算结果
        本金: \(currencyManager.formatAmount(result.principal))
        年利率: \(String(format: "%.2f", result.rate))%
        投资期限: \(result.years)年
        复利频率: \(result.frequency)
        最终金额: \(currencyManager.formatAmount(result.finalAmount))
        利息收益: \(currencyManager.formatAmount(result.totalInterest))
        收益率: \(String(format: "%.2f", result.totalInterest / result.principal * 100))%
        """
    }
}

struct DetailRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(HistoryManager())
        .environmentObject(CurrencyManager())
}