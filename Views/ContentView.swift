//
//  ContentView.swift
//  复利计算器
//
//  Created by ROOT. on 2025/3/20.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var historyManager = HistoryManager()
    @StateObject private var currencyManager = CurrencyManager()
    
    var body: some View {
        TabView {
            CalculatorView()
                .environmentObject(historyManager)
                .environmentObject(currencyManager)
                .tabItem {
                    Image(systemName: "function")
                    Text("计算器")
                }
            
            HistoryView()
                .environmentObject(historyManager)
                .environmentObject(currencyManager)
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("历史")
                }
            
            SettingsView()
                .environmentObject(currencyManager)
                .environmentObject(historyManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
        }
    }
}

#Preview {
    ContentView()
}