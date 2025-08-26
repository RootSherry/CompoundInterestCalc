# 复利计算器 iOS App

![iOS](https://img.shields.io/badge/iOS-15.0%2B-blue)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-orange)
![Swift](https://img.shields.io/badge/Swift-5.7%2B-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## 项目介绍

复利计算器是一款专为 iOS 平台设计的现代化复利计算应用。该应用采用 SwiftUI 框架开发，具有简洁直观的用户界面和强大的计算功能。无论您是个人投资者、金融顾问还是正在进行财务规划的用户，这款应用都能帮助您快速准确地计算复利收益，并通过图表直观地展示投资增长趋势。

### 核心价值

- **精准计算**：基于标准复利公式，支持不同频率的复利计算
- **数据可视化**：使用 Swift Charts 框架，直观展示收益增长趋势
- **历史管理**：完整保存计算历史，支持添加备注和分享
- **多货币支持**：支持人民币、美元、欧元、英镑等多种货币单位
- **现代设计**：遵循 iOS 设计规范，提供流畅的用户体验

## 功能特点

### 💰 复利计算
- 输入本金、年化利率、投资周期和复利频率
- 支持年、季度、月、日四种复利频率
- 实时显示最终收益、利息收益和收益率
- 安全的数值处理，防止计算溢出

### 📊 图表可视化
- 基于 Swift Charts 的交互式图表
- 逐年收益增长趋势展示
- 支持点线图展示，直观易懂
- 自动过滤异常数据点

### 📝 历史记录管理
- 自动保存每次计算结果
- 支持为每条记录添加备注
- 计算时间戳记录
- 支持删除和清空历史记录

### 💱 多货币支持
- 内置 7 种常用货币：人民币、美元、欧元、英镑、日元、港币、韩元、澳元
- 智能货币格式化显示
- 货币偏好自动保存

### 📤 分享功能
- 一键生成计算结果报告
- 支持系统分享功能
- 包含完整计算参数和结果

## 技术架构

### 开发框架
- **SwiftUI 3.0+**：现代化声明式 UI 框架
- **Swift Charts**：原生图表框架，提供高性能数据可视化
- **Foundation**：核心数据处理和持久化

### 架构设计
```
CompoundInterestApp/
├── Models/                 # 数据模型层
│   ├── CalculationModel.swift    # 复利计算核心逻辑
│   ├── CurrencyManager.swift     # 货币管理
│   └── HistoryManager.swift      # 历史记录管理
├── Views/                  # 用户界面层
│   ├── ContentView.swift         # 主容器视图
│   ├── CalculatorView.swift      # 计算器界面
│   ├── HistoryView.swift         # 历史记录界面
│   └── SettingsView.swift        # 设置界面
├── Assets.xcassets         # 应用资源
└── CompoundInterestApp.swift     # 应用入口
```

### 核心组件

#### CalculationModel
- `CompoundFrequency`：复利频率枚举（年/季度/月/日）
- `CalculationResult`：计算结果数据结构
- `CompoundInterestCalculator`：核心计算引擎

#### 数据管理
- `HistoryManager`：使用 UserDefaults 进行本地数据持久化
- `CurrencyManager`：货币偏好管理和格式化

#### 用户界面
- 基于 TabView 的三标签页设计
- 响应式布局，同时支持 iPhone 和 iPad
- 无障碍访问支持

## 安装要求

### 系统要求
- **iOS 15.0** 或更高版本
- **iPadOS 15.0** 或更高版本
- 兼容 iPhone 和 iPad 全系列设备

### 开发要求
- **Xcode 14.0+**
- **Swift 5.7+**
- **macOS Monterey 12.0+**

## 使用指南

### 基本计算
1. 在"计算器"标签页输入：
   - 本金金额
   - 年化利率（百分比）
   - 投资年限
   - 选择复利频率
2. 点击"计算"按钮查看结果
3. 查看图表了解收益增长趋势

### 历史管理
1. 切换到"历史"标签页
2. 查看所有历史计算记录
3. 点击任意记录查看详细信息
4. 添加备注或分享结果

### 设置配置
1. 在"设置"标签页可以：
   - 更改货币单位
   - 清空历史记录
   - 查看应用信息

## 开发信息

### 版本历史
- **v1.0.0** (2025-03-20)
  - 初始版本发布
  - 基本复利计算功能
  - 图表可视化
  - 历史记录管理
  - 多货币支持

### 技术特性
- **MVVM 架构模式**：清晰的代码组织结构
- **响应式编程**：基于 SwiftUI 的声明式 UI
- **数据持久化**：本地数据存储
- **类型安全**：全面的 Swift 类型系统支持
- **错误处理**：完善的边界条件处理

### 性能优化
- 异步计算处理，避免 UI 阻塞
- 数值溢出保护机制
- 图表数据过滤和优化
- 内存管理优化

## 贡献指南

欢迎提交 Issues 和 Pull Requests 来改进这个项目。

### 开发设置
1. 克隆仓库到本地
2. 使用 Xcode 打开项目
3. 选择目标设备或模拟器
4. 点击运行按钮开始调试

### 代码规范
- 遵循 Swift 官方编码规范
- 使用有意义的变量和函数命名
- 添加必要的注释和文档
- 保持代码简洁和可读性

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 联系信息

- **开发者**：ROOT
- **创建时间**：2025年3月20日
- **项目地址**：[GitHub Repository](https://github.com/RootSherry/CompoundInterestCalc)

---

© 2025 复利计算器. 保留所有权利.