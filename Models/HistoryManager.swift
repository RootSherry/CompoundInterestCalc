//
//  HistoryManager.swift
//  复利计算器
//
//  Created by ROOT. on 2025/3/20.
//

import Foundation
import SwiftUI

class HistoryManager: ObservableObject {
    @Published var history: [CalculationResult] = []
    
    private let saveKey = "compoundInterestHistory"
    
    init() {
        loadHistory()
    }
    
    func addToHistory(_ result: CalculationResult) {
        history.insert(result, at: 0)
        saveHistory()
    }
    
    func updateNote(for id: UUID, with note: String) {
        if let index = history.firstIndex(where: { $0.id == id }) {
            history[index].note = note
            saveHistory()
        }
    }
    
    func deleteRecord(at indexSet: IndexSet) {
        history.remove(atOffsets: indexSet)
        saveHistory()
    }
    
    func clearAllHistory() {
        history.removeAll()
        saveHistory()
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadHistory() {
        if let savedHistory = UserDefaults.standard.data(forKey: saveKey),
           let decodedHistory = try? JSONDecoder().decode([CalculationResult].self, from: savedHistory) {
            history = decodedHistory
        }
    }
}