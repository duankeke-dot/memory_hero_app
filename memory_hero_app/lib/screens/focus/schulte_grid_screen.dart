import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

import '../../providers/training_provider.dart';
import '../../providers/child_profile_provider.dart';
import '../../models/training_record.dart';

/// 舒尔特方格 - 视觉注意力训练
class SchulteGridScreen extends StatefulWidget {
  const SchulteGridScreen({super.key});

  @override
  State<SchulteGridScreen> createState() => _SchulteGridScreenState();
}

class _SchulteGridScreenState extends State<SchulteGridScreen> {
  int _gridSize = 5;
  List<int> _numbers = [];
  int _currentNumber = 1;
  int _startTime = 0;
  int _elapsedTime = 0;
  bool _isPlaying = false;
  bool _isComplete = false;
  int _mistakes = 0;
  
  @override
  void initState() {
    super.initState();
    _generateGrid();
  }
  
  void _generateGrid() {
    final random = Random();
    _numbers = List.generate(_gridSize * _gridSize, (i) => i + 1)..shuffle(random);
  }
  
  void _startGame() {
    setState(() {
      _currentNumber = 1;
      _startTime = DateTime.now().millisecondsSinceEpoch;
      _elapsedTime = 0;
      _isPlaying = true;
      _isComplete = false;
      _mistakes = 0;
      _generateGrid();
    });
    
    // 开始计时
    _startTimer();
  }
  
  void _startTimer() async {
    while (_isPlaying && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted && _isPlaying) {
        setState(() {
          _elapsedTime = DateTime.now().millisecondsSinceEpoch - _startTime;
        });
      }
    }
  }
  
  void _onNumberTap(int number) {
    if (!_isPlaying || _isComplete) return;
    
    if (number == _currentNumber) {
      // 正确
      setState(() {
        _currentNumber++;
      });
      
      // 检查是否完成
      if (_currentNumber > _gridSize * _gridSize) {
        _completeGame();
      }
    } else {
      // 错误
      setState(() {
        _mistakes++;
      });
      
      // 震动反馈
      HapticFeedback.vibrate();
    }
  }
  
  void _completeGame() {
    setState(() {
      _isPlaying = false;
      _isComplete = true;
    });
    _saveResult();
  }
  
  void _saveResult() {
    final childProvider = context.read<ChildProfileProvider>();
    final trainingProvider = context.read<TrainingProvider>();
    final child = childProvider.currentChild;
    
    if (child == null) return;
    
    // 计算得分（基于时间和错误）
    final baseScore = 100;
    final timePenalty = _elapsedTime ~/ 1000; // 每秒扣 1 分
    final mistakePenalty = _mistakes * 5; // 每个错误扣 5 分
    final finalScore = (baseScore - timePenalty - mistakePenalty).clamp(0, 100).toInt();
    
    final record = TrainingRecord.create(
      childId: child.id,
      moduleId: 'schulte_grid',
      moduleName: '舒尔特方格',
      trainingType: TrainingType.focus,
      difficulty: _gridSize,
    ).copyWith(
      score: finalScore,
      maxScore: 100,
      completed: true,
      endTime: DateTime.now(),
      durationSeconds: _elapsedTime ~/ 1000,
      details: {'mistakes': _mistakes, 'elapsedMs': _elapsedTime},
    );
    
    trainingProvider.saveRecord(record);
  }
  
  String _formatTime(int ms) {
    final seconds = (ms / 1000).toStringAsFixed(2);
    return '$seconds 秒';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('舒尔特方格'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Text(
                _formatTime(_elapsedTime),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
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
                  _buildStatBox('进度', '${_currentNumber - 1}/${_gridSize * _gridSize}'),
                  _buildStatBox('错误', '$_mistakes'),
                  _buildStatBox('目标', '按顺序点击'),
                ],
              ),
            ),
            
            // 游戏区域
            Expanded(
              child: _isPlaying || _isComplete
                  ? _buildGameGrid()
                  : _buildStartScreen(),
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
              fontSize: 20,
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
          const Text('🎯', style: TextStyle(fontSize: 80)),
          SizedBox(height: 24.h),
          const Text(
            '舒尔特方格',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          const Text(
            '从 1 开始按顺序点击所有数字\n越快越好！',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 48.h),
          ElevatedButton(
            onPressed: _startGame,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text('开始游戏', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameGrid() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _gridSize,
              mainAxisSpacing: 8.w,
              crossAxisSpacing: 8.w,
            ),
            itemCount: _numbers.length,
            itemBuilder: (context, index) {
              return _buildGridCell(_numbers[index]);
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildGridCell(int number) {
    final isNext = number == _currentNumber;
    final isCompleted = number < _currentNumber;
    
    return GestureDetector(
      onTap: () => _onNumberTap(number),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppTheme.accentColor
              : isNext
                  ? AppTheme.primaryColor.withOpacity(0.3)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isNext ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isNext ? 3 : 1,
          ),
          boxShadow: isNext
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: isCompleted ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
