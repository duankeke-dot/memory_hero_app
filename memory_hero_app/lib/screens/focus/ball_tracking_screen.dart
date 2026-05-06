import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import '../../providers/training_provider.dart';
import '../../providers/child_profile_provider.dart';
import '../../models/training_record.dart';

/// 追踪小球 - 视觉追踪训练
class BallTrackingScreen extends StatefulWidget {
  const BallTrackingScreen({super.key});

  @override
  State<BallTrackingScreen> createState() => _BallTrackingScreenState();
}

class _BallTrackingScreenState extends State<BallTrackingScreen> with SingleTickerProviderStateMixin {
  int _level = 1;
  int _score = 0;
  int _currentRound = 0;
  int _maxRounds = 5;
  bool _isPlaying = false;
  bool _isComplete = false;
  
  // 球的位置
  Offset _ballPosition = Offset.zero;
  Offset _targetPosition = Offset.zero;
  
  // 动画
  late AnimationController _animationController;
  late Animation<Offset> _ballAnimation;
  
  // 追踪时间
  int _trackTime = 0; // 秒
  bool _isTracking = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('追踪小球'),
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
                  _buildStatBox('进度', '$_currentRound/$_maxRounds'),
                  _buildStatBox('时间', '${_trackTime}s'),
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
        color: AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.warningColor,
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
          const Text('⚽', style: TextStyle(fontSize: 80)),
          SizedBox(height: 24.h),
          const Text(
            '追踪小球',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          const Text(
            '用眼睛跟随移动的小球\n锻炼视觉追踪能力',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 48.h),
          ElevatedButton(
            onPressed: _startGame,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text('开始训练', style: TextStyle(fontSize: 20)),
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
            _isTracking ? '用眼睛跟随小球！' : '准备开始...',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        
        // 游戏区域
        Expanded(
          child: GestureDetector(
            onTap: _isTracking ? _markCorrect : null,
            child: Container(
              margin: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Stack(
                  children: [
                    // 背景网格
                    _buildGrid(),
                    
                    // 小球
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Positioned(
                          left: _ballPosition.dx - 30,
                          top: _ballPosition.dy - 30,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.warningColor.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('⚽', style: TextStyle(fontSize: 30)),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // 控制按钮
        Padding(
          padding: EdgeInsets.all(24.w),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isTracking ? null : _startTracking,
                  child: Text(
                    _isTracking ? '追踪中...' : '开始追踪',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isTracking ? _markCorrect : null,
                  child: const Text('我看到了', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildGrid() {
    return CustomPaint(
      size: Size.infinite,
      painter: GridPainter(),
    );
  }
  
  Widget _buildCompleteScreen() {
    final accuracy = (_score / _maxRounds * 100).toInt();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            accuracy >= 80 ? '🌟' : accuracy >= 60 ? '👍' : '💪',
            style: const TextStyle(fontSize: 80),
          ),
          SizedBox(height: 24.h),
          Text(
            accuracy >= 80 ? '太棒了！' : accuracy >= 60 ? '不错！' : '继续加油！',
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
      _level = 1;
      _score = 0;
      _currentRound = 0;
      _isComplete = false;
      _trackTime = 0;
      _isTracking = false;
    });
    _startRound();
  }
  
  void _startRound() {
    if (_currentRound >= _maxRounds) {
      _finishGame();
      return;
    }
    
    final random = math.Random();
    final size = MediaQuery.of(context).size;
    
    // 随机起点和终点
    _ballPosition = Offset(
      size.width * 0.2 + random.nextDouble() * size.width * 0.6,
      size.height * 0.2 + random.nextDouble() * size.height * 0.6,
    );
    
    _targetPosition = Offset(
      size.width * 0.2 + random.nextDouble() * size.width * 0.6,
      size.height * 0.2 + random.nextDouble() * size.height * 0.6,
    );
    
    // 创建动画
    _ballAnimation = OffsetTween(
      begin: _ballPosition,
      end: _targetPosition,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.addListener(() {
      setState(() {
        _ballPosition = _ballAnimation.value;
      });
    });
    
    setState(() {
      _isTracking = true;
      _trackTime = 2 + _level; // 关卡越高时间越长
    });
    
    // 开始动画
    _animationController.duration = Duration(seconds: _trackTime);
    _animationController.forward(from: 0);
    
    // 倒计时
    _startCountdown();
  }
  
  void _startCountdown() async {
    for (int i = _trackTime; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isTracking) {
        setState(() {
          _trackTime = i - 1;
        });
      }
    }
    
    if (mounted && _isTracking) {
      setState(() {
        _isTracking = false;
      });
    }
  }
  
  void _markCorrect() {
    if (!_isTracking) return;
    
    setState(() {
      _score++;
      _currentRound++;
      _trackTime = 0;
      _isTracking = false;
      _animationController.stop();
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _startRound();
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
      if (_level < 5) {
        _level++;
      }
      _currentRound = 0;
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
    
    final accuracy = (_score / _maxRounds * 100).toInt();
    
    final record = TrainingRecord.create(
      childId: child.id,
      moduleId: 'ball_tracking',
      moduleName: '追踪小球',
      trainingType: TrainingType.focus,
      difficulty: _level,
    ).copyWith(
      score: accuracy.clamp(0, 100),
      maxScore: 100,
      completed: true,
      endTime: DateTime.now(),
      durationSeconds: 0,
    );
    
    trainingProvider.saveRecord(record);
  }
}

/// 网格绘制器
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 1;
    
    // 绘制横线和竖线
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  
  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}
