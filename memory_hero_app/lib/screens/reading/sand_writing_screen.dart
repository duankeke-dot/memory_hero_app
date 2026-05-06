import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import '../../providers/training_provider.dart';
import '../../providers/child_profile_provider.dart';
import '../../models/training_record.dart';

/// 沙盘写字 - 多感官识字训练
class SandWritingScreen extends StatefulWidget {
  const SandWritingScreen({super.key});

  @override
  State<SandWritingScreen> createState() => _SandWritingScreenState();
}

class _SandWritingScreenState extends State<SandWritingScreen> {
  List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _isDrawing = false;
  bool _isPlaying = false;
  int _level = 1;
  int _score = 0;
  int _currentIndex = 0;
  
  // 示例汉字（按难度分级）
  final List<List<String>> _characterLevels = [
    ['一', '二', '三', '十', '人'],  // Level 1
    ['大', '小', '上', '下', '口'],  // Level 2
    ['日', '月', '水', '火', '山'],  // Level 3
    ['木', '禾', '土', '石', '田'],  // Level 4
    ['中', '国', '学', '生', '好'],  // Level 5
  ];
  
  String get _currentCharacter {
    final level = math.min(_level - 1, _characterLevels.length - 1);
    return _characterLevels[level][_currentIndex % _characterLevels[level].length];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('沙盘写字'),
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
                  _buildStatBox('字符', _currentCharacter),
                  _buildStatBox('进度', '${_currentIndex + 1}/5'),
                ],
              ),
            ),
            
            // 游戏区域
            Expanded(
              child: _isPlaying ? _buildDrawingArea() : _buildStartScreen(),
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
          const Text('📝', style: TextStyle(fontSize: 80)),
          SizedBox(height: 24.h),
          const Text(
            '沙盘写字',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          const Text(
            '用手指在沙盘上临摹汉字\n多感官学习，加深记忆',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 48.h),
          ElevatedButton(
            onPressed: _startGame,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text('开始练习', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawingArea() {
    return Column(
      children: [
        // 提示区域
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              const Text(
                '请临摹下面的汉字',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8.h),
              Text(
                _currentCharacter,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        
        // 画布区域
        Expanded(
          child: Container(
            margin: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5E6D3), // 沙盘颜色
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFD4C5B0), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  painter: SandDrawingPainter(
                    strokes: _strokes,
                    currentStroke: _currentStroke,
                    backgroundColor: const Color(0xFFF5E6D3),
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),
        
        // 控制按钮
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearCanvas,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('清空'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _nextCharacter,
                  icon: const Icon(Icons.check),
                  label: const Text('下一个'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _startGame() {
    setState(() {
      _isPlaying = true;
      _level = 1;
      _score = 0;
      _currentIndex = 0;
      _strokes = [];
      _currentStroke = [];
    });
  }
  
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _currentStroke = [details.localPosition];
    });
  }
  
  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawing) return;
    
    setState(() {
      _currentStroke.add(details.localPosition);
    });
  }
  
  void _onPanEnd(DragEndDetails details) {
    if (!_isDrawing) return;
    
    setState(() {
      _isDrawing = false;
      if (_currentStroke.isNotEmpty) {
        _strokes.add(_currentStroke);
        _currentStroke = [];
      }
    });
    
    // 简单评分：根据绘制轨迹数量
    if (_strokes.length >= 1) {
      _score += 10;
    }
  }
  
  void _clearCanvas() {
    setState(() {
      _strokes = [];
      _currentStroke = [];
    });
  }
  
  void _nextCharacter() {
    setState(() {
      _currentIndex++;
      if (_currentIndex >= 5) {
        _currentIndex = 0;
        _level++;
      }
      _strokes = [];
      _currentStroke = [];
    });
    
    // 完成一轮后保存结果
    if (_currentIndex == 0 && _level > 1) {
      _saveResult();
    }
  }
  
  void _saveResult() {
    final childProvider = context.read<ChildProfileProvider>();
    final trainingProvider = context.read<TrainingProvider>();
    final child = childProvider.currentChild;
    
    if (child == null) return;
    
    final record = TrainingRecord.create(
      childId: child.id,
      moduleId: 'sand_writing',
      moduleName: '沙盘写字',
      trainingType: TrainingType.reading,
      difficulty: _level,
    ).copyWith(
      score: _score.clamp(0, 100),
      maxScore: 100,
      completed: true,
      endTime: DateTime.now(),
      durationSeconds: 0,
      details: {'level': _level, 'characters': _currentIndex},
    );
    
    trainingProvider.saveRecord(record);
  }
}

/// 沙盘绘制器
class SandDrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color backgroundColor;
  
  SandDrawingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.backgroundColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景
    final paint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // 绘制沙盘纹理
    _drawSandTexture(canvas, size);
    
    // 绘制已完成的笔画
    final strokePaint = Paint()
      ..color = const Color(0xFF8B7355)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    for (final stroke in strokes) {
      if (stroke.isNotEmpty) {
        final path = Path()..moveTo(stroke[0].dx, stroke[0].dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, strokePaint);
      }
    }
    
    // 绘制当前笔画
    if (currentStroke.isNotEmpty) {
      final path = Path()..moveTo(currentStroke[0].dx, currentStroke[0].dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }
      canvas.drawPath(path, strokePaint);
    }
  }
  
  void _drawSandTexture(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()
      ..color = const Color(0x208B7355)
      ..strokeWidth = 1;
    
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }
  
  @override
  bool shouldRepaint(SandDrawingPainter oldDelegate) {
    return oldDelegate.strokes != strokes || oldDelegate.currentStroke != currentStroke;
  }
}
