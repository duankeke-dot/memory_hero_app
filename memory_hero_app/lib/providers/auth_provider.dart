import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 认证状态提供者
class AuthProvider extends ChangeNotifier {
  String? _userId;
  String? _parentName;
  String? _email;
  String? _phone;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  String? get userId => _userId;
  String? get parentName => _parentName;
  String? get email => _email;
  String? get phone => _phone;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// 初始化 - 从本地存储加载登录状态
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('user_id');
      _parentName = prefs.getString('parent_name');
      _email = prefs.getString('email');
      _phone = prefs.getString('phone');
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    } catch (e) {
      _error = '初始化失败：$e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  /// 注册
  Future<bool> register({
    required String parentName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // TODO: 实际项目中这里应该调用后端 API
      // 模拟注册成功
      await Future.delayed(const Duration(seconds: 1));
      
      _userId = const Uuid().v4();
      _parentName = parentName;
      _email = email;
      _phone = phone;
      
      // 保存到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _userId!);
      await prefs.setString('parent_name', parentName);
      await prefs.setString('email', email);
      await prefs.setString('phone', phone);
      await prefs.setBool('is_logged_in', true);
      
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '注册失败：$e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// 登录
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // TODO: 实际项目中这里应该调用后端 API
      // 模拟登录成功
      await Future.delayed(const Duration(seconds: 1));
      
      _userId = const Uuid().v4();
      _parentName = '家长';
      _email = email;
      
      // 保存到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _userId!);
      await prefs.setString('parent_name', _parentName!);
      await prefs.setString('email', email);
      await prefs.setBool('is_logged_in', true);
      
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '登录失败：$e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// 退出登录
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _userId = null;
      _parentName = null;
      _email = null;
      _phone = null;
      _isLoggedIn = false;
      
      notifyListeners();
    } catch (e) {
      _error = '退出登录失败：$e';
      notifyListeners();
    }
  }
  
  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
