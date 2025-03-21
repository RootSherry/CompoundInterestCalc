//
//  SettingsView.swift
//  复利计算器
//
//  Created by ROOT. on 2025/3/20.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var currencyManager: CurrencyManager
    @EnvironmentObject private var historyManager: HistoryManager
    @State private var showingConfirmation = false
    @State private var showAbout = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("货币设置")) {
                    Picker("货币单位", selection: $currencyManager.selectedCurrency) {
                        ForEach(currencyManager.currencies) { currency in
                            HStack {
                                Text(currency.name)
                                Text("(\(currency.symbol))")
                                    .foregroundColor(.secondary)
                            }
                            .tag(currency)
                        }
                    }
                }
                
                Section(header: Text("数据管理")) {
                    Button("清除所有历史记录") {
                        showingConfirmation = true
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("关于")) {
                    Button("关于复利计算器") {
                        showAbout = true
                    }
                    
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .alert("确认删除", isPresented: $showingConfirmation) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    historyManager.clearAllHistory()
                }
            } message: {
                Text("确定要删除所有历史记录吗？此操作无法撤销。")
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("复利计算器")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("版本 1.0.0")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("这是一款简洁易用的复利计算器应用，帮助您：")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "快速计算复利收益")
                    FeatureRow(icon: "clock.arrow.circlepath", text: "保存历史计算记录")
                    FeatureRow(icon: "chart.bar.fill", text: "图表展示收益增长趋势")
                    FeatureRow(icon: "square.and.arrow.up", text: "分享计算结果")
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
                .padding(.horizontal)
                
                Spacer()
                
                Text("© 2025 复利计算器")
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .frame(width: 25, height: 25)
                .foregroundColor(.blue)
            Text(text)
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(CurrencyManager())
        .environmentObject(HistoryManager())
}