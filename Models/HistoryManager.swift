//
//  HistoryManager.swift
//  复利计算器
//
//  Created by ROOT. on 2025/3/20.
//

import Foundation
import SwiftUI

/// 历史记录管理器
/// Manages the storage and retrieval of calculation history
class HistoryManager: ObservableObject {
    @Published var history: [CalculationResult] = []
    
    private let saveKey = "compoundInterestHistory"
    
    /// 历史记录数量上限
    static let maxHistoryCount = 100
    
    init() {
        loadHistory()
    }
    
    /// 添加新的计算结果到历史记录
    /// - Parameter result: 要添加的计算结果
    func addToHistory(_ result: CalculationResult) {
        history.insert(result, at: 0)
        
        // 限制历史记录数量
        if history.count > HistoryManager.maxHistoryCount {
            history = Array(history.prefix(HistoryManager.maxHistoryCount))
        }
        
        saveHistory()
    }
    
    /// 更新指定记录的备注
    /// - Parameters:
    ///   - id: 记录的唯一标识符
    ///   - note: 新的备注内容
    func updateNote(for id: UUID, with note: String) {
        if let index = history.firstIndex(where: { $0.id == id }) {
            history[index].note = note
            saveHistory()
        }
    }
    
    /// 删除指定位置的记录
    /// - Parameter indexSet: 要删除的索引集合
    func deleteRecord(at indexSet: IndexSet) {
        history.remove(atOffsets: indexSet)
        saveHistory()
    }
    
    /// 删除指定ID的记录
    /// - Parameter id: 要删除记录的ID
    func deleteRecord(withId id: UUID) {
        history.removeAll { $0.id == id }
        saveHistory()
    }
    
    /// 清空所有历史记录
    func clearAllHistory() {
        history.removeAll()
        saveHistory()
    }
    
    /// 检查是否有历史记录
    var hasHistory: Bool {
        return !history.isEmpty
    }
    
    /// 获取历史记录数量
    var historyCount: Int {
        return history.count
    }
    
    /// 保存历史记录到 UserDefaults
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    /// 从 UserDefaults 加载历史记录
    private func loadHistory() {
        if let savedHistory = UserDefaults.standard.data(forKey: saveKey),
           let decodedHistory = try? JSONDecoder().decode([CalculationResult].self, from: savedHistory) {
            history = decodedHistory
        }
    }
}