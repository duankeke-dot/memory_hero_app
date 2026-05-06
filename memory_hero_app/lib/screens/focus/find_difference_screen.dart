import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import '../../providers/training_provider.dart';
import '../../providers/child_profile_provider.dart';
import '../../models/training_record.dart';

/// 找不同 - 视觉辨别训练
class FindDifferenceScreen extends StatefulWidget {
  const FindDifferenceScreen({super.key});

  @override
  State<FindDifferenceScreen> createState() => _FindDifferenceScreenState();
}

class _FindDifferenceScreenState extends State<FindDifferenceScreen> {
  int _level = 1;
  int _score = 0;
  int _currentIndex = 0;
  int _maxLevels = 5;
  bool _isPlaying = false;
  bool _isComplete = false;
  
  // 找到的不同数量
  int _foundDifferences = 0;
  int _totalDifferences = 3;
  
  // 点击位置
  List<Offset> _clickPositions = [];
  List<int> _correctClicks = []; // 正确点击的索引
  
  // 差异位置（归一化坐标 0-1）
  List<Offset> _differencePositions = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('找不同'),
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
                  _buildStatBox('关卡', '$_level'),
                  _buildStatBox('找到', '$_foundDifferences/$_totalDifferences'),
                  _buildStatBox('进度', '${_currentIndex + 1}/$_maxLevels'),
                ],
              ),
            ),
            
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
        color: AppTheme.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.infoColor,
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
          const Text('🔍', style: TextStyle(fontSize: 80)),
          SizedBox(height: 24.h),
          const Text(
            '找不同',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          const Text(
            '找出两张图片的不同之处\n锻炼观察力和专注力',
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
  
  Widget _buildGameArea() {
    if (_isComplete) {
      return _buildCompleteScreen();
    }
    
    return Column(
      children: [
        // 提示
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            '点击两幅图的不同之处（共 $_totalDifferences 处）',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        
        // 图片区域
        Expanded(
          child: Row(
            children: [
              // 左图
              Expanded(
                child: _buildImagePanel(isLeft: true),
              ),
              // 分隔线
              Container(
                width: 2.w,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                color: Colors.grey[300],
              ),
              // 右图
              Expanded(
                child: _buildImagePanel(isLeft: false),
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
                  onPressed: _resetLevel,
                  child: const Text('重置', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _foundDifferences >= _totalDifferences ? _nextLevel : null,
                  child: const Text('继续', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildImagePanel({required bool isLeft}) {
    return GestureDetector(
      onTapDown: (details) => _onTap(details.localPosition, isLeft),
      child: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: CustomPaint(
            painter: DifferenceImagePainter(
              isLeft: isLeft,
              differences: _differencePositions,
              foundDifferences: _correctClicks.toSet(),
              clickPositions: _clickPositions
                  .asMap()
                  .entries
                  .where((e) => (isLeft && e.key % 2 == 0) || (!isLeft && e.key % 2 == 1))
                  .map((e) => e.value)
                  .toList(),
              level: _level,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
  
  Widget _buildCompleteScreen() {
    final accuracy = (_score / (_maxLevels * _totalDifferences) * 100).toInt();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            accuracy >= 80 ? '🏆' : accuracy >= 60 ? '🌟' : '💪',
            style: const TextStyle(fontSize: 80),
          ),
          SizedBox(height: 24.h),
          Text(
            accuracy >= 80 ? '完美！' : accuracy >= 60 ? '很棒！' : '继续加油！',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Text(
            '得分：$_score',
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
                  child: Text('再玩一次', style: TextStyle(fontSize: 18)),
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
      _level = 1;
      _score = 0;
      _currentIndex = 0;
      _isComplete = false;
      _generateLevel();
    });
  }
  
  void _generateLevel() {
    final random = math.Random();
    _totalDifferences = 2 + _level; // 关卡越高差异越多
    _foundDifferences = 0;
    _clickPositions = [];
    _correctClicks = [];
    
    // 生成随机差异位置
    _differencePositions = List.generate(
      _totalDifferences,
      (_) => Offset(
        0.2 + random.nextDouble() * 0.6,
        0.2 + random.nextDouble() * 0.6,
      ),
    );
  }
  
  void _onTap(Offset position, bool isLeft) {
    if (_isComplete) return;
    
    setState(() {
      _clickPositions.add(position);
    });
    
    // 检查是否点击到差异位置
    final screenSize = MediaQuery.of(context).size;
    final normalizedPosition = Offset(
      position.dx / (screenSize.width / 2),
      position.dy / screenSize.height,
    );
    
    bool foundNewDifference = false;
    for (int i = 0; i < _differencePositions.length; i++) {
      if (_correctClicks.contains(i)) continue;
      
      final diff = _differencePositions[i];
      final distance = (normalizedPosition - diff).distance;
      
      if (distance < 0.15) {
        // 找到差异
        foundNewDifference = true;
        _correctClicks.add(i);
        _foundDifferences++;
        _score += 10;
        break;
      }
    }
    
    // 检查是否完成
    if (_foundDifferences >= _totalDifferences) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _currentIndex++;
            if (_currentIndex >= _maxLevels) {
              _isComplete = true;
              _saveResult();
            } else {
              _generateLevel();
            }
          });
        }
      });
    }
  }
  
  void _resetLevel() {
    setState(() {
      _foundDifferences = 0;
      _clickPositions = [];
      _correctClicks = [];
      _generateLevel();
    });
  }
  
  void _nextLevel() {
    if (_isComplete) {
      // 重新开始
      _startGame();
    } else {
      setState(() {
        _currentIndex++;
        if (_currentIndex >= _maxLevels) {
          _isComplete = true;
          _saveResult();
        } else {
          _generateLevel();
        }
      });
    }
  }
  
  void _saveResult() {
    final childProvider = context.read<ChildProfileProvider>();
    final trainingProvider = context.read<TrainingProvider>();
    final child = childProvider.currentChild;
    
    if (child == null) return;
    
    final record = TrainingRecord.create(
      childId: child.id,
      moduleId: 'find_difference',
      moduleName: '找不同',
      trainingType: TrainingType.focus,
      difficulty: _level,
    ).copyWith(
      score: _score.clamp(0, 100),
      maxScore: 100,
      completed: true,
      endTime: DateTime.now(),
      durationSeconds: 0,
    );
    
    trainingProvider.saveRecord(record);
  }
}

/// 差异图片绘制器
class DifferenceImagePainter extends CustomPainter {
  final bool isLeft;
  final List<Offset> differences;
  final Set<int> foundDifferences;
  final List<Offset> clickPositions;
  final int level;
  
  DifferenceImagePainter({
    required this.isLeft,
    required this.differences,
    required this.foundDifferences,
    required this.clickPositions,
    required this.level,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景
    final bgPaint = Paint()..color = _getBackgroundColor();
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    // 绘制简单图形（模拟图片内容）
    _drawScene(canvas, size);
    
    // 绘制差异（只在右图隐藏某些元素）
    if (!isLeft) {
      _drawDifferences(canvas, size);
    }
    
    // 绘制点击标记
    _drawClickMarkers(canvas, size);
  }
  
  Color _getBackgroundColor() {
    final colors = [
      const Color(0xFFE3F2FD),
      const Color(0xFFE8F5E9),
      const Color(0xFFFFF3E0),
      const Color(0xFFF3E5F5),
      const Color(0xFFFFEBEE),
    ];
    return colors[level % colors.length];
  }
  
  void _drawScene(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // 绘制一些简单图形
    final random = math.Random(42 + level);
    
    // 圆形
    for (int i = 0; i < 5; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 20 + random.nextDouble() * 30;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
    
    // 矩形
    for (int i = 0; i < 3; i++) {
      final x = random.nextDouble() * size.width * 0.5;
      final y = random.nextDouble() * size.height * 0.5;
      canvas.drawRect(
        Rect.fromLTWH(x, y, 50, 50),
        paint,
      );
    }
    
    // 三角形
    for (int i = 0; i < 2; i++) {
      final path = Path();
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      path.moveTo(x, y);
      path.lineTo(x + 30, y + 50);
      path.lineTo(x - 30, y + 50);
      path.close();
      canvas.drawPath(path, paint);
    }
  }
  
  void _drawDifferences(Canvas canvas, Size size) {
    // 在右图隐藏一些元素（通过绘制背景色覆盖）
    final coverPaint = Paint()..color = _getBackgroundColor();
    
    for (int i = 0; i < differences.length; i++) {
      if (foundDifferences.contains(i)) continue;
      
      final x = differences[i].dx * size.width;
      final y = differences[i].dy * size.height;
      
      // 覆盖一个小圆形
      canvas.drawCircle(Offset(x, y), 30, coverPaint);
    }
  }
  
  void _drawClickMarkers(Canvas canvas, Size size) {
    for (int i = 0; i < clickPositions.length; i++) {
      final position = clickPositions[i];
      final isCorrect = i < foundDifferences.length && foundDifferences.contains(i ~/ 2);
      
      canvas.drawCircle(
        position,
        20,
        Paint()
          ..color = isCorrect ? Colors.green : Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      
      // 绘制 X 或 ✓
      final textPainter = TextPainter(
        text: TextSpan(
          text: isCorrect ? '✓' : '✗',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2),
      );
    }
  }
  
  @override
  bool shouldRepaint(DifferenceImagePainter oldDelegate) {
    return oldDelegate.foundDifferences != foundDifferences ||
        oldDelegate.clickPositions != clickPositions;
  }
}
