import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/child_profile.dart';

/// 儿童档案状态提供者
class ChildProfileProvider extends ChangeNotifier {
  List<ChildProfile> _children = [];
  ChildProfile? _currentChild;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<ChildProfile> get children => _children;
  ChildProfile? get currentChild => _currentChild;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasChildren => _children.isNotEmpty;
  
  /// 初始化 - 加载所有儿童档案
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final childrenJson = prefs.getStringList('children_profiles');
      
      if (childrenJson != null && childrenJson.isNotEmpty) {
        _children = childrenJson
            .map((json) => ChildProfile.fromJson(jsonDecode(json)))
            .toList();
        
        // 加载当前儿童
        final currentChildId = prefs.getString('current_child_id');
        if (currentChildId != null) {
          _currentChild = _children.firstWhere(
            (c) => c.id == currentChildId,
            orElse: () => _children.first,
          );
        } else if (_children.isNotEmpty) {
          _currentChild = _children.first;
        }
      }
    } catch (e) {
      _error = '加载档案失败：$e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  /// 添加儿童档案
  Future<bool> addChild(ChildProfile child) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _children.add(child);
      
      if (_currentChild == null) {
        _currentChild = child;
      }
      
      await _saveChildren();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '添加档案失败：$e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// 更新儿童档案
  Future<bool> updateChild(ChildProfile child) async {
    try {
      final index = _children.indexWhere((c) => c.id == child.id);
      if (index == -1) return false;
      
      _children[index] = child;
      
      if (_currentChild?.id == child.id) {
        _currentChild = child;
      }
      
      await _saveChildren();
      notifyListeners();
      return true;
    } catch (e) {
      _error = '更新档案失败：$e';
      notifyListeners();
      return false;
    }
  }
  
  /// 删除儿童档案
  Future<bool> deleteChild(String childId) async {
    try {
      _children.removeWhere((c) => c.id == childId);
      
      if (_currentChild?.id == childId) {
        _currentChild = _children.isNotEmpty ? _children.first : null;
      }
      
      await _saveChildren();
      notifyListeners();
      return true;
    } catch (e) {
      _error = '删除档案失败：$e';
      notifyListeners();
      return false;
    }
  }
  
  /// 切换当前儿童
  Future<void> switchChild(String childId) async {
    try {
      _currentChild = _children.firstWhere(
        (c) => c.id == childId,
        orElse: () => throw Exception('未找到该儿童档案'),
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_child_id', childId);
      
      notifyListeners();
    } catch (e) {
      _error = '切换档案失败：$e';
      notifyListeners();
    }
  }
  
  /// 更新能力评估
  Future<void> updateAssessment(AbilityAssessment assessment) async {
    if (_currentChild == null) return;
    
    final updated = _currentChild!.copyWith(assessment: assessment);
    await updateChild(updated);
  }
  
  /// 保存所有儿童档案到本地存储
  Future<void> _saveChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final childrenJson = _children
        .map((c) => jsonEncode(c.toJson()))
        .toList();
    await prefs.setStringList('children_profiles', childrenJson);
    
    if (_currentChild != null) {
      await prefs.setString('current_child_id', _currentChild!.id);
    }
  }
  
  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
