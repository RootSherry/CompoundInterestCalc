# 复利计算器 iOS App

![iOS](https://img.shields.io/badge/iOS-15.0%2B-blue)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

复利计算器是一款简洁易用的 iOS 应用程序，旨在帮助用户快速计算复利收益。用户可以输入初始本金、利率、投资周期和复利频率，实时查看最终收益和总回报。适用于个人投资者、金融顾问以及需要进行财务规划的用户。

## 功能特点

* **复利计算**：输入本金、年化利率、投资周期和复利频率，快速计算复利收益
* **多种复利频率**：支持年、季度、月、日等不同的复利频率选择
* **历史记录**：保存计算历史，支持添加备注
* **图表展示**：直观展示收益增长趋势
* **多种货币**：支持多种货币单位切换
* **分享功能**：生成收益报告并分享
* **无障碍支持**：完整的 VoiceOver 支持
* **触觉反馈**：计算成功/失败时提供触觉反馈

## 系统要求

* iOS 15.0 或更高版本
* 兼容 iPhone 和 iPad

## 项目结构

```
CompoundInterestCalc/
├── CompoundInterestApp.swift    # 应用入口
├── Models/
│   ├── CalculationModel.swift   # 复利计算核心逻辑
│   ├── CurrencyManager.swift    # 货币管理
│   └── HistoryManager.swift     # 历史记录管理
├── Views/
│   ├── ContentView.swift        # 主视图（TabView）
│   ├── CalculatorView.swift     # 计算器视图
│   ├── HistoryView.swift        # 历史记录视图
│   └── SettingsView.swift       # 设置视图
└── Assets.xcassets/             # 资源文件
```

## 技术亮点

### 1. 输入验证
- 实时验证用户输入
- 友好的错误提示信息
- 防止无效计算

### 2. 数值安全处理
- 防止计算溢出
- 处理 NaN 和无限值
- 限制最大计算年限（100年）

### 3. 无障碍设计
- 完整的 VoiceOver 支持
- 语义化的 accessibility labels
- 图表数据的无障碍描述

### 4. 用户体验
- 触觉反馈（成功/错误）
- 平滑的动画过渡
- 键盘工具栏快捷操作

## 优化建议

以下是项目可继续优化的方向：

### 短期优化
1. **单元测试**：为复利计算逻辑添加完整的单元测试
2. **UI 测试**：添加 UI 自动化测试确保用户流程正常
3. **深色模式**：优化深色模式下的图表颜色
4. **iPad 适配**：优化 iPad 上的布局展示

### 中期优化
1. **本地化**：添加英语等多语言支持
2. **Widget**：添加桌面小组件显示最近计算结果
3. **定期投资**：支持定期定额投资计算
4. **数据导出**：支持导出历史记录为 CSV/PDF
5. **iCloud 同步**：通过 iCloud 同步历史记录

### 长期优化
1. **Apple Watch**：开发 watchOS 配套应用
2. **Shortcuts**：支持 Siri Shortcuts 快捷指令
3. **税收计算**：考虑税收影响的收益计算
4. **投资组合**：支持多个投资项目组合计算
5. **通胀调整**：考虑通胀因素的实际收益计算

## 开发说明

### 构建项目
1. 使用 Xcode 14.0 或更高版本打开项目
2. 选择目标设备或模拟器
3. 点击 Run (⌘R) 构建并运行

### 代码规范
- 使用 Swift 官方代码风格
- 所有公开 API 需添加文档注释
- 使用有意义的变量和函数命名

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件