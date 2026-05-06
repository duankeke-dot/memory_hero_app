import 'package:flutter/material.dart';

/// 儿童档案模型
class ChildProfile {
  final String id;
  final String name;
  final DateTime birthDate;
  final String grade;
  final String? avatarUrl;
  
  // 能力评估
  final AbilityAssessment assessment;
  
  // 训练偏好
  final TrainingPreferences preferences;
  
  // 创建和更新时间
  final DateTime createdAt;
  final DateTime updatedAt;
  
  ChildProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.grade,
    this.avatarUrl,
    required this.assessment,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });
  
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
  
  ChildProfile copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? grade,
    String? avatarUrl,
    AbilityAssessment? assessment,
    TrainingPreferences? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      grade: grade ?? this.grade,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      assessment: assessment ?? this.assessment,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'grade': grade,
      'avatarUrl': avatarUrl,
      'assessment': assessment.toJson(),
      'preferences': preferences.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      grade: json['grade'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      assessment: AbilityAssessment.fromJson(json['assessment'] as Map<String, dynamic>),
      preferences: TrainingPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  
  /// 创建默认档案
  factory ChildProfile.defaultProfile() {
    return ChildProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '宝贝',
      birthDate: DateTime.now().subtract(const Duration(days: 3285)), // 约 9 岁
      grade: '三年级',
      assessment: AbilityAssessment.defaultAssessment(),
      preferences: TrainingPreferences.defaultPreferences(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

/// 能力评估
class AbilityAssessment {
  // 各项能力评分 (0-100)
  final int workingMemory;      // 工作记忆
  final int visualTracking;     // 视觉追踪
  final int readingFluency;     // 朗读流畅
  final int attention;          // 注意力
  final int characterRecognition; // 字形认知
  final int auditoryMemory;     // 听觉记忆
  
  const AbilityAssessment({
    required this.workingMemory,
    required this.visualTracking,
    required this.readingFluency,
    required this.attention,
    required this.characterRecognition,
    required this.auditoryMemory,
  });
  
  AbilityAssessment.defaultAssessment()
      : workingMemory = 50,
        visualTracking = 50,
        readingFluency = 50,
        attention = 50,
        characterRecognition = 50,
        auditoryMemory = 50;
  
  AbilityAssessment copyWith({
    int? workingMemory,
    int? visualTracking,
    int? readingFluency,
    int? attention,
    int? characterRecognition,
    int? auditoryMemory,
  }) {
    return AbilityAssessment(
      workingMemory: workingMemory ?? this.workingMemory,
      visualTracking: visualTracking ?? this.visualTracking,
      readingFluency: readingFluency ?? this.readingFluency,
      attention: attention ?? this.attention,
      characterRecognition: characterRecognition ?? this.characterRecognition,
      auditoryMemory: auditoryMemory ?? this.auditoryMemory,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'workingMemory': workingMemory,
      'visualTracking': visualTracking,
      'readingFluency': readingFluency,
      'attention': attention,
      'characterRecognition': characterRecognition,
      'auditoryMemory': auditoryMemory,
    };
  }
  
  factory AbilityAssessment.fromJson(Map<String, dynamic> json) {
    return AbilityAssessment(
      workingMemory: json['workingMemory'] as int,
      visualTracking: json['visualTracking'] as int,
      readingFluency: json['readingFluency'] as int,
      attention: json['attention'] as int,
      characterRecognition: json['characterRecognition'] as int,
      auditoryMemory: json['auditoryMemory'] as int,
    );
  }
  
  /// 获取能力雷达图数据
  List<Map<String, dynamic>> get radarData {
    return [
      {'name': '工作记忆', 'value': workingMemory},
      {'name': '视觉追踪', 'value': visualTracking},
      {'name': '朗读流畅', 'value': readingFluency},
      {'name': '注意力', 'value': attention},
      {'name': '字形认知', 'value': characterRecognition},
      {'name': '听觉记忆', 'value': auditoryMemory},
    ];
  }
}

/// 训练偏好
class TrainingPreferences {
  final Duration sessionDuration;     // 单次训练时长
  final int reminderTime;             // 提醒时间 (小时)
  final bool soundEnabled;            // 音效开关
  final bool musicEnabled;            // 背景音乐开关
  final double fontSize;              // 字体大小
  final String themeColor;            // 主题颜色
  
  const TrainingPreferences({
    required this.sessionDuration,
    required this.reminderTime,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.fontSize,
    required this.themeColor,
  });
  
  TrainingPreferences.defaultPreferences()
      : sessionDuration = const Duration(minutes: 15),
        reminderTime = 19, // 晚上 7 点
        soundEnabled = true,
        musicEnabled = true,
        fontSize = 18.0,
        themeColor = 'blue';
  
  TrainingPreferences copyWith({
    Duration? sessionDuration,
    int? reminderTime,
    bool? soundEnabled,
    bool? musicEnabled,
    double? fontSize,
    String? themeColor,
  }) {
    return TrainingPreferences(
      sessionDuration: sessionDuration ?? this.sessionDuration,
      reminderTime: reminderTime ?? this.reminderTime,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      fontSize: fontSize ?? this.fontSize,
      themeColor: themeColor ?? this.themeColor,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'sessionDuration': sessionDuration.inMinutes,
      'reminderTime': reminderTime,
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'fontSize': fontSize,
      'themeColor': themeColor,
    };
  }
  
  factory TrainingPreferences.fromJson(Map<String, dynamic> json) {
    return TrainingPreferences(
      sessionDuration: Duration(minutes: json['sessionDuration'] as int),
      reminderTime: json['reminderTime'] as int,
      soundEnabled: json['soundEnabled'] as bool,
      musicEnabled: json['musicEnabled'] as bool,
      fontSize: json['fontSize'] as double,
      themeColor: json['themeColor'] as String,
    );
  }
}
