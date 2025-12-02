//
//  HistoryManagerTests.swift
//  复利计算器Tests
//
//  Created by ROOT. on 2025/3/20.
//

import XCTest
@testable import CompoundInterestCalc

final class HistoryManagerTests: XCTestCase {
    
    var historyManager: HistoryManager!
    
    override func setUp() {
        super.setUp()
        historyManager = HistoryManager()
        // 清除历史记录以确保测试独立性
        historyManager.clearAllHistory()
    }
    
    override func tearDown() {
        historyManager.clearAllHistory()
        historyManager = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func createSampleResult(principal: Double = 10000) -> CalculationResult {
        return CompoundInterestCalculator.calculate(
            principal: principal,
            rate: 5,
            years: 1,
            frequency: .annually
        )
    }
    
    // MARK: - Add to History Tests
    
    func testAddToHistory() {
        let result = createSampleResult()
        historyManager.addToHistory(result)
        
        XCTAssertEqual(historyManager.historyCount, 1)
        XCTAssertTrue(historyManager.hasHistory)
    }
    
    func testAddMultipleToHistory() {
        let result1 = createSampleResult(principal: 10000)
        let result2 = createSampleResult(principal: 20000)
        
        historyManager.addToHistory(result1)
        historyManager.addToHistory(result2)
        
        XCTAssertEqual(historyManager.historyCount, 2)
    }
    
    func testAddToHistoryInsertsAtBeginning() {
        let result1 = createSampleResult(principal: 10000)
        let result2 = createSampleResult(principal: 20000)
        
        historyManager.addToHistory(result1)
        historyManager.addToHistory(result2)
        
        // 最新添加的应该在最前面
        XCTAssertEqual(historyManager.history.first?.principal, 20000)
    }
    
    // MARK: - Update Note Tests
    
    func testUpdateNote() {
        let result = createSampleResult()
        historyManager.addToHistory(result)
        
        let noteText = "测试备注"
        historyManager.updateNote(for: result.id, with: noteText)
        
        XCTAssertEqual(historyManager.history.first?.note, noteText)
    }
    
    func testUpdateNoteForNonExistentId() {
        let result = createSampleResult()
        historyManager.addToHistory(result)
        
        let nonExistentId = UUID()
        historyManager.updateNote(for: nonExistentId, with: "测试")
        
        // 原始备注应该保持不变
        XCTAssertEqual(historyManager.history.first?.note, "")
    }
    
    // MARK: - Delete Tests
    
    func testDeleteRecordAtIndex() {
        let result1 = createSampleResult(principal: 10000)
        let result2 = createSampleResult(principal: 20000)
        
        historyManager.addToHistory(result1)
        historyManager.addToHistory(result2)
        
        historyManager.deleteRecord(at: IndexSet(integer: 0))
        
        XCTAssertEqual(historyManager.historyCount, 1)
        XCTAssertEqual(historyManager.history.first?.principal, 10000)
    }
    
    func testDeleteRecordWithId() {
        let result1 = createSampleResult(principal: 10000)
        let result2 = createSampleResult(principal: 20000)
        
        historyManager.addToHistory(result1)
        historyManager.addToHistory(result2)
        
        historyManager.deleteRecord(withId: result2.id)
        
        XCTAssertEqual(historyManager.historyCount, 1)
        XCTAssertEqual(historyManager.history.first?.principal, 10000)
    }
    
    // MARK: - Clear History Tests
    
    func testClearAllHistory() {
        historyManager.addToHistory(createSampleResult())
        historyManager.addToHistory(createSampleResult())
        historyManager.addToHistory(createSampleResult())
        
        historyManager.clearAllHistory()
        
        XCTAssertEqual(historyManager.historyCount, 0)
        XCTAssertFalse(historyManager.hasHistory)
    }
    
    // MARK: - History Count Limit Tests
    
    func testHistoryCountLimit() {
        // 添加超过最大限制数量的记录
        for i in 0..<(HistoryManager.maxHistoryCount + 10) {
            historyManager.addToHistory(createSampleResult(principal: Double(i * 1000)))
        }
        
        // 应该被限制在最大数量
        XCTAssertLessThanOrEqual(historyManager.historyCount, HistoryManager.maxHistoryCount)
    }
    
    // MARK: - Has History Tests
    
    func testHasHistoryWhenEmpty() {
        XCTAssertFalse(historyManager.hasHistory)
    }
    
    func testHasHistoryWhenNotEmpty() {
        historyManager.addToHistory(createSampleResult())
        XCTAssertTrue(historyManager.hasHistory)
    }
}
