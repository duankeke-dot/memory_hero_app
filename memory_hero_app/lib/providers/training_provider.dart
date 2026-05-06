import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/training_record.dart';
import '../models/child_profile.dart';

/// 训练状态提供者
class TrainingProvider extends ChangeNotifier {
  List<TrainingRecord> _records = [];
  Map<String, int> _moduleLevels = {}; // 模块等级
  Map<String, int> _moduleStars = {};  // 模块星星数
  int _totalStars = 0;
  int _consecutiveDays = 0;
  DateTime? _lastTrainingDate;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<TrainingRecord> get records => _records;
  Map<String, int> get moduleLevels => _moduleLevels;
  Map<String, int> get moduleStars => _moduleStars;
  int get totalStars => _totalStars;
  int get consecutiveDays => _consecutiveDays;
  DateTime? get lastTrainingDate => _lastTrainingDate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// 获取今日训练记录
  List<TrainingRecord> get todayRecords {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _records.where((r) {
      final recordDate = DateTime(r.startTime.year, r.startTime.month, r.startTime.day);
      return recordDate == today;
    }).toList();
  }
  
  /// 获取本周训练记录
  List<TrainingRecord> get weekRecords {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _records.where((r) => r.startTime.isAfter(weekAgo)).toList();
  }
  
  /// 获取指定模块的记录
  List<TrainingRecord> getModuleRecords(String moduleId) {
    return _records.where((r) => r.moduleId == moduleId).toList();
  }
  
  /// 获取训练统计数据
  TrainingStats getStats() {
    final totalSessions = _records.length;
    final totalMinutes = _records.fold<int>(
      0,
      (sum, r) => sum + (r.durationSeconds ~/ 60),
    );
    final avgAccuracy = _records.isNotEmpty
        ? _records.fold<double>(0, (sum, r) => sum + r.accuracy) / _records.length
        : 0.0;
    
    // 计算各类型训练次数
    final readingCount = _records.where((r) => r.trainingType == TrainingType.reading).length;
    final memoryCount = _records.where((r) => r.trainingType == TrainingType.memory).length;
    final focusCount = _records.where((r) => r.trainingType == TrainingType.focus).length;
    
    return TrainingStats(
      totalSessions: totalSessions,
      totalMinutes: totalMinutes,
      avgAccuracy: avgAccuracy,
      readingCount: readingCount,
      memoryCount: memoryCount,
      focusCount: focusCount,
    );
  }
  
  /// 初始化
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载训练记录
      final recordsJson = prefs.getStringList('training_records');
      if (recordsJson != null) {
        _records = recordsJson
            .map((json) => TrainingRecord.fromJson(jsonDecode(json)))
            .toList();
      }
      
      // 加载模块等级
      final levelsJson = prefs.getString('module_levels');
      if (levelsJson != null) {
        _moduleLevels = Map<String, int>.from(jsonDecode(levelsJson));
      }
      
      // 加载星星数
      _totalStars = prefs.getInt('total_stars') ?? 0;
      final starsJson = prefs.getString('module_stars');
      if (starsJson != null) {
        _moduleStars = Map<String, int>.from(jsonDecode(starsJson));
      }
      
      // 加载连续天数
      _consecutiveDays = prefs.getInt('consecutive_days') ?? 0;
      final lastDateStr = prefs.getString('last_training_date');
      if (lastDateStr != null) {
        _lastTrainingDate = DateTime.parse(lastDateStr);
      }
      
      // 检查连续天数
      await _checkConsecutiveDays();
    } catch (e) {
      _error = '加载训练数据失败：$e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  /// 保存训练记录
  Future<void> saveRecord(TrainingRecord record) async {
    try {
      _records.add(record);
      
      // 更新模块星星
      final currentStars = _moduleStars[record.moduleId] ?? 0;
      int earnedStars = 0;
      if (record.accuracy >= 0.9) earnedStars = 3;
      else if (record.accuracy >= 0.7) earnedStars = 2;
      else if (record.accuracy >= 0.5) earnedStars = 1;
      
      if (earnedStars > currentStars) {
        _moduleStars[record.moduleId] = earnedStars;
        _totalStars += (earnedStars - currentStars);
      }
      
      // 更新连续天数
      await _updateConsecutiveDays();
      
      // 保存到本地存储
      await _saveData();
      
      notifyListeners();
    } catch (e) {
      _error = '保存记录失败：$e';
      notifyListeners();
    }
  }
  
  /// 更新模块等级
  Future<void> updateModuleLevel(String moduleId, int level) async {
    _moduleLevels[moduleId] = level;
    await _saveData();
    notifyListeners();
  }
  
  /// 保存数据到本地存储
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 保存记录
    final recordsJson = _records
        .map((r) => jsonEncode(r.toJson()))
        .toList();
    await prefs.setStringList('training_records', recordsJson);
    
    // 保存等级
    await prefs.setString('module_levels', jsonEncode(_moduleLevels));
    
    // 保存星星
    await prefs.setInt('total_stars', _totalStars);
    await prefs.setString('module_stars', jsonEncode(_moduleStars));
    
    // 保存连续天数
    await prefs.setInt('consecutive_days', _consecutiveDays);
    if (_lastTrainingDate != null) {
      await prefs.setString('last_training_date', _lastTrainingDate!.toIso8601String());
    }
  }
  
  /// 检查并更新连续天数
  Future<void> _checkConsecutiveDays() async {
    if (_lastTrainingDate == null) {
      _consecutiveDays = 0;
      return;
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(_lastTrainingDate!.year, _lastTrainingDate!.month, _lastTrainingDate!.day);
    final diff = today.difference(lastDate).inDays;
    
    if (diff > 1) {
      // 中断了
      _consecutiveDays = 0;
    } else if (diff == 1) {
      // 昨天训练过，保持连续
    } else if (diff == 0) {
      // 今天已经训练过
    }
  }
  
  /// 更新连续天数
  Future<void> _updateConsecutiveDays() async {
    if (_lastTrainingDate == null) {
      _consecutiveDays = 1;
    } else {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastDate = DateTime(_lastTrainingDate!.year, _lastTrainingDate!.month, _lastTrainingDate!.day);
      final diff = today.difference(lastDate).inDays;
      
      if (diff == 1) {
        _consecutiveDays++;
      } else if (diff > 1) {
        _consecutiveDays = 1;
      }
    }
    
    _lastTrainingDate = now;
  }
  
  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// 训练统计数据
class TrainingStats {
  final int totalSessions;
  final int totalMinutes;
  final double avgAccuracy;
  final int readingCount;
  final int memoryCount;
  final int focusCount;
  
  const TrainingStats({
    required this.totalSessions,
    required this.totalMinutes,
    required this.avgAccuracy,
    required this.readingCount,
    required this.memoryCount,
    required this.focusCount,
  });
}
