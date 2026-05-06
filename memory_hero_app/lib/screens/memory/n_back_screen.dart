import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import '../../providers/training_provider.dart';
import '../../providers/child_profile_provider.dart';
import '../../models/training_record.dart';

/// N-Back 挑战 - 工作记忆训练
class NBackScreen extends StatefulWidget {
  const NBackScreen({super.key});

  @override
  State<NBackScreen> createState() => _NBackScreenState();
}

class _NBackScreenState extends State<NBackScreen> {
  int _level = 1; // N 值，从 1 开始
  int _score = 0;
  int _currentIndex = 0;
  int _totalRounds = 10;
  bool _isPlaying = false;
  bool _isShowingStimulus = false;
  bool _isComplete = false;
  
  // 当前刺激
  String _currentStimulus = '';
  List<String> _stimulusHistory = [];
  
  // 刺激选项
  final List<String> _stimuli = ['🍎', '🍊', '🍇', '🍓', '🍒', '🍑', '🥝', '🍌'];
  
  int get nValue => _level;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('N-Back 挑战'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Text(
                '得分：$_score',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 状态栏
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatBox('N 值', '$_level'),
                  _buildStatBox('进度', '$_currentIndex/$_totalRounds'),
                  _buildStatBox('正确', '$_score'),
                ],
              ),
            ),
            
            // 说明
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                '当当前图案与 ${_level} 个之前的图案相同时，点击"相同"',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // 游戏区域
            Expanded(
              child: _isPlaying ? _buildGameArea() : _buildStartScreen(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatBox(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧠', style: TextStyle(fontSize: 80)),
          SizedBox(height: 24.h),
          const Text(
            'N-Back 挑战',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          const Text(
            '锻炼工作记忆的经典训练\n记住之前的图案并做出判断',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 48.h),
          ElevatedButton(
            onPressed: _startGame,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text('开始挑战', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameArea() {
    if (_isComplete) {
      return _buildCompleteScreen();
    }
    
    return Column(
      children: [
        // 刺激显示区
        Expanded(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isShowingStimulus
                  ? Container(
                      width: 150.w,
                      height: 150.w,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _currentStimulus,
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    )
                  : Container(
                      width: 150.w,
                      height: 150.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '?',
                          style: TextStyle(fontSize: 80, color: Colors.grey),
                        ),
                      ),
                    ),
            ),
          ),
        ),
        
        // 历史提示
        Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              const Text(
                '历史记录（最近的 N 个）',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: _stimulusHistory
                    .take(nValue)
                    .map((s) => Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(s, style: const TextStyle(fontSize: 24)),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        
        // 控制按钮
        Padding(
          padding: EdgeInsets.all(24.w),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isShowingStimulus ? null : () => _respond(false),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                  ),
                  child: const Text('不同', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isShowingStimulus ? null : () => _respond(true),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                  ),
                  child: const Text('相同', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCompleteScreen() {
    final accuracy = _totalRounds > 0 ? (_score / _totalRounds * 100).toInt() : 0;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            accuracy >= 80 ? '🏆' : accuracy >= 60 ? '👍' : '💪',
            style: const TextStyle(fontSize: 80),
          ),
          SizedBox(height: 24.h),
          Text(
            accuracy >= 80 ? '优秀！' : accuracy >= 60 ? '不错！' : '继续加油！',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Text(
            '正确率：$accuracy%',
            style: const TextStyle(fontSize: 24),
          ),
          SizedBox(height: 48.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _nextLevel,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Text('继续', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(width: 16.w),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('退出', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _startGame() {
    setState(() {
      _isPlaying = true;
      _score = 0;
      _currentIndex = 0;
      _isComplete = false;
      _stimulusHistory = [];
      _currentStimulus = '';
    });
    _nextStimulus();
  }
  
  void _nextStimulus() {
    if (_currentIndex >= _totalRounds) {
      _finishGame();
      return;
    }
    
    final random = math.Random();
    
    // 30% 概率生成与 N 个前相同的刺激
    bool isMatch = false;
    if (_stimulusHistory.length >= nValue && random.nextDouble() < 0.3) {
      _currentStimulus = _stimulusHistory[_stimulusHistory.length - nValue];
      isMatch = true;
    } else {
      // 随机选择刺激，但要避免意外匹配
      List<String> available = List.from(_stimuli);
      if (_stimulusHistory.length >= nValue) {
        available.remove(_stimulusHistory[_stimulusHistory.length - nValue]);
      }
      _currentStimulus = available[random.nextInt(available.length)];
    }
    
    setState(() {
      _isShowingStimulus = true;
    });
    
    // 显示 1.5 秒后隐藏
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isShowingStimulus = false;
          _stimulusHistory.insert(0, _currentStimulus);
          if (_stimulusHistory.length > 10) {
            _stimulusHistory = _stimulusHistory.sublist(0, 10);
          }
        });
      }
    });
  }
  
  void _respond(bool isSame) {
    if (!_isPlaying || _isShowingStimulus) return;
    
    // 检查是否正确
    bool actualMatch = false;
    if (_stimulusHistory.length > 1) {
      // 当前刺激是 history[0]，N 个前是 history[nValue]
      if (_stimulusHistory.length > nValue) {
        actualMatch = _stimulusHistory[0] == _stimulusHistory[nValue];
      }
    }
    
    if (isSame == actualMatch) {
      // 回答正确
      setState(() {
        _score++;
      });
    }
    
    setState(() {
      _currentIndex++;
    });
    
    // 下一个刺激
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _nextStimulus();
    });
  }
  
  void _finishGame() {
    setState(() {
      _isComplete = true;
      _isPlaying = false;
    });
    _saveResult();
  }
  
  void _nextLevel() {
    setState(() {
      if (_level < 3) {
        _level++;
      }
      _currentIndex = 0;
      _score = 0;
      _isComplete = false;
    });
    _startGame();
  }
  
  void _saveResult() {
    final childProvider = context.read<ChildProfileProvider>();
    final trainingProvider = context.read<TrainingProvider>();
    final child = childProvider.currentChild;
    
    if (child == null) return;
    
    final accuracy = (_score / _totalRounds * 100).toInt();
    
    final record = TrainingRecord.create(
      childId: child.id,
      moduleId: 'n_back',
      moduleName: 'N-Back 挑战',
      trainingType: TrainingType.memory,
      difficulty: _level,
    ).copyWith(
      score: accuracy.clamp(0, 100),
      maxScore: 100,
      completed: true,
      endTime: DateTime.now(),
      durationSeconds: 0,
      details: {'nValue': nValue, 'correct': _score, 'total': _totalRounds},
    );
    
    trainingProvider.saveRecord(record);
  }
}
