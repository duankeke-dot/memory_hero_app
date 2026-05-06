# 记忆小超人 - 儿童认知训练 APP

一款专为阅读障碍和记忆障碍儿童设计的认知训练应用，通过游戏化的方式帮助孩子提升阅读能力、记忆力和专注力。

## 📱 项目概述

**目标用户**: 7-12 岁有阅读障碍/记忆障碍的儿童  
**技术栈**: Flutter 3.x (跨平台 iOS/Android)  
**设计理念**: 游戏化训练 + 科学干预 + 进度可视化

## 🎯 核心功能

### 训练模块

| 模块 | 游戏 | 训练目标 |
|------|------|---------|
| **阅读训练** | 沙盘写字、汉字拼图、彩色阅读、朗读挑战 | 字形认知、视觉追踪、朗读流畅 |
| **记忆训练** | 数字接龙、记忆翻牌、N-Back 挑战、故事回忆 | 工作记忆、视觉记忆、听觉记忆 |
| **专注力** | 舒尔特方格、追踪小球、找不同 | 视觉注意力、持续注意、反应速度 |
| **感统游戏** | 平衡挑战、节奏大师、触觉猜猜 | 前庭觉、本体觉、触觉辨别 |

### 家长功能

- 📊 实时进度看板
- 📈 能力雷达图
- 📅 训练记录追踪
- 📤 报告导出
- ⚙️ 个性化设置

### 激励机制

- ⭐ 星星奖励系统
- 🏆 成就徽章
- 🔥 连续打卡
- 🎮 等级系统

## 🏗️ 项目结构

```
memory_hero_app/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── config/
│   │   ├── theme.dart               # 主题配置
│   │   └── routes.dart              # 路由配置
│   ├── models/
│   │   ├── child_profile.dart       # 儿童档案模型
│   │   └── training_record.dart     # 训练记录模型
│   ├── providers/
│   │   ├── auth_provider.dart       # 认证状态
│   │   ├── child_profile_provider.dart  # 儿童档案状态
│   │   └── training_provider.dart   # 训练状态
│   ├── screens/
│   │   ├── splash_screen.dart       # 启动页
│   │   ├── onboarding/              # 引导页
│   │   ├── auth/                    # 登录注册
│   │   ├── home/                    # 首页
│   │   ├── reading/                 # 阅读训练
│   │   ├── memory/                  # 记忆训练
│   │   ├── focus/                   # 专注力训练
│   │   ├── parent/                  # 家长控制台
│   │   └── ...
│   ├── widgets/                     # 可复用组件
│   ├── services/                    # 服务层
│   └── utils/                       # 工具类
├── assets/
│   ├── images/                      # 图片资源
│   ├── fonts/                       # 字体文件
│   └── audio/                       # 音频文件
├── test/                            # 测试文件
└── pubspec.yaml                     # 依赖配置
```

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- iOS 12.0+ / Android 6.0+

### 安装步骤

```bash
# 1. 克隆项目
cd memory_hero_app

# 2. 安装依赖
flutter pub get

# 3. 运行应用
flutter run

# 4. 构建发布版本
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### 开发环境配置

```bash
# 检查 Flutter 环境
flutter doctor

# 运行代码生成 (如果使用 Hive 等)
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📦 核心依赖

```yaml
dependencies:
  # 状态管理
  provider: ^6.1.1
  flutter_bloc: ^8.1.3
  
  # 本地存储
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  
  # 图表
  fl_chart: ^0.65.0
  
  # 动画
  lottie: ^2.7.0
  animate_do: ^3.1.2
  
  # 音频
  audioplayers: ^5.2.1
  
  # UI
  flutter_screenutil: ^5.9.0
```

## 🎨 设计规范

### 颜色系统

```dart
// 主色调
primaryColor: #4FC3F7      // 浅蓝色
secondaryColor: #FFB74D    // 橙色
accentColor: #81C784       // 绿色

// 功能色
successColor: #66BB6A
warningColor: #FFA726
errorColor: #EF5350
```

### 字体规范

- 默认字体：18pt (阅读障碍友好)
- 大字体：22pt
- 超大字体：28pt
- 支持自定义字体大小

### 无障碍设计

- ✅ 大按钮 (≥44×44pt)
- ✅ 高对比度 (≥4.5:1)
- ✅ 可调节字体大小
- ✅ 支持 TTS 朗读
- ✅ 简洁界面减少干扰

## 📊 数据模型

### 儿童档案 (ChildProfile)

```dart
{
  id: String,
  name: String,
  birthDate: DateTime,
  grade: String,
  assessment: AbilityAssessment,
  preferences: TrainingPreferences,
}
```

### 能力评估 (AbilityAssessment)

```dart
{
  workingMemory: int,      // 工作记忆 0-100
  visualTracking: int,     // 视觉追踪 0-100
  readingFluency: int,     // 朗读流畅 0-100
  attention: int,          // 注意力 0-100
  characterRecognition: int, // 字形认知 0-100
  auditoryMemory: int,     // 听觉记忆 0-100
}
```

### 训练记录 (TrainingRecord)

```dart
{
  id: String,
  moduleId: String,
  moduleName: String,
  trainingType: TrainingType,
  score: int,
  maxScore: int,
  difficulty: int,
  completed: bool,
  durationSeconds: int,
}
```

## 🎮 游戏实现示例

### 数字接龙 (Number Sequence)

```dart
// 核心逻辑
1. 生成随机数字序列 (长度随等级增加)
2. 逐个显示数字 (800ms/个)
3. 用户按顺序复述
4. 实时反馈正确/错误
5. 完成 5 轮后结算得分
```

### 记忆翻牌 (Memory Flip)

```dart
// 核心逻辑
1. 生成配对卡片 (3x4 网格)
2. 用户翻牌寻找匹配
3. 记录步数
4. 根据效率计算得分
```

### 舒尔特方格 (Schulte Grid)

```dart
// 核心逻辑
1. 生成 5x5 随机数字网格
2. 用户从 1 开始按顺序点击
3. 记录时间和错误
4. 综合计算得分
```

## 🔒 隐私与安全

- 所有数据本地存储 (可选云同步)
- 符合 COPPA 儿童隐私保护
- 无第三方广告
- 家长授权机制

## 📱 平台适配

### Android

```bash
# 最低版本
minSdkVersion 21

# 权限配置
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

### iOS

```bash
# 最低版本
platform :ios, '12.0'

# Info.plist 配置
<key>NSMicrophoneUsageDescription</key>
<string>用于朗读训练录音</string>
```

## 🧪 测试

```bash
# 运行单元测试
flutter test

# 运行集成测试
flutter test integration_test/

# 代码覆盖率
flutter test --coverage
```

## 📈 开发路线图

### Phase 1 (已完成) ✅
- [x] 项目基础架构
- [x] 用户认证系统
- [x] 核心数据模型
- [x] 3 个训练游戏
- [x] 家长控制台

### Phase 2 (进行中) 🚧
- [ ] 剩余训练游戏
- [ ] 成就系统
- [ ] 数据可视化报告
- [ ] 个性化训练计划

### Phase 3 (计划中) 📋
- [ ] AI 自适应难度
- [ ] 云同步
- [ ] 社交功能
- [ ] 医院/学校对接

## 🤝 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 👥 团队

- 产品：儿童认知训练专家
- 开发：Flutter 开发团队
- 设计：UI/UX 设计师
- 顾问：儿童心理学家

## 📞 联系方式

- 项目主页：[待定]
- 问题反馈：[待定]
- 商务合作：[待定]

## 🙏 致谢

感谢所有为儿童认知训练研究做出贡献的科学家和教育工作者！

---

**让学习变得更有趣！🌟**
