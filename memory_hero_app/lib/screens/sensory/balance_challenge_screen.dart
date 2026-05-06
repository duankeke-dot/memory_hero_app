import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import '../../providers/training_provider.dart';
import '../../providers/child_profile_provider.dart';
import '../../models/training_record.dart';

/// 平衡挑战 - 前庭觉训练（使用设备陀螺仪模拟）
class BalanceChallengeScreen extends StatefulWidget {
  const BalanceChallengeScreen({super.key});

  @override
  State<BalanceChallengeScreen> createState() => _BalanceChallengeScreenState();
}

class _BalanceChallengeScreenState extends State<BalanceChallengeScreen> with SingleTickerProviderStateMixin {
  int _level = 1;
  int _score = 0;
  int _currentRound = 0;
  int _maxRounds = 3;
  bool _isPlaying = false;
  bool _isComplete = false;
  
  // 球的位置（-1 到 1）
  double _ballX = 0.0;
  double _ballY = 0.0;
  
  // 目标位置
  double _targetX = 0.0;
  double _targetY = 0.0;
  
  // 平衡时间
  int _balanceTime = 0;
  int _requiredTime = 5;
  bool _isBalancing = false;
  
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animationController.addListener(_updateBallPosition);
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
        title: const Text('平衡挑战'),
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
                  _buildStatBox('时间', '$_balanceTime/$_requiredTime'),
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
          const Text('⚖️', style: TextStyle(fontSize: 80)),
          SizedBox(height: 24.h),
          const Text(
            '平衡挑战',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          const Text(
            '滑动屏幕控制小球保持平衡\n锻炼手眼协调能力',
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
        // 提示
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            _isBalancing ? '保持小球在绿色区域！' : '将小球移到绿色区域',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        
        // 平衡台
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.grey[300]!, width: 3),
                ),
                child: CustomPaint(
                  painter: BalanceBoardPainter(
                    ballX: _ballX,
                    ballY: _ballY,
                    targetX: _targetX,
                    targetY: _targetY,
                    isBalancing: _isBalancing,
                    level: _level,
                  ),
                  size: Size.infinite,
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
                  onPressed: _isBalancing ? null : _startBalancing,
                  child: Text(
                    _isBalancing ? '保持平衡中...' : '开始平衡',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isBalancing ? null : _resetBall,
                  child: const Text('重置', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCompleteScreen() {
    final accuracy = (_score / (_maxRounds * 10) * 100).toInt();
    
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
            accuracy >= 80 ? '平衡大师！' : accuracy >= 60 ? '很不错！' : '继续练习！',
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
      _startRound();
    });
  }
  
  void _startRound() {
    if (_currentRound >= _maxRounds) {
      _finishGame();
      return;
    }
    
    final random = math.Random();
    setState(() {
      _ballX = (random.nextDouble() - 0.5) * 1.5;
      _ballY = (random.nextDouble() - 0.5) * 1.5;
      _targetX = (random.nextDouble() - 0.5) * 0.5;
      _targetY = (random.nextDouble() - 0.5) * 0.5;
      _balanceTime = 0;
      _requiredTime = 3 + _level;
      _isBalancing = false;
    });
  }
  
  void _startBalancing() {
    // 检查小球是否在目标区域
    final distance = math.sqrt(
      math.pow(_ballX - _targetX, 2) + math.pow(_ballY - _targetY, 2),
    );
    
    if (distance > 0.3) {
      // 小球不在目标区域
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('先将小球移到绿色区域！'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    
    setState(() {
      _isBalancing = true;
    });
    
    // 开始计时
    _startTimer();
  }
  
  void _startTimer() async {
    while (_isBalancing && mounted && _balanceTime < _requiredTime) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isBalancing) {
        setState(() {
          _balanceTime++;
        });
      }
    }
    
    if (mounted && _isBalancing && _balanceTime >= _requiredTime) {
      // 成功
      setState(() {
        _score += 10;
        _currentRound++;
        _isBalancing = false;
      });
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _startRound();
      });
    }
  }
  
  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isPlaying || _isBalancing) return;
    
    setState(() {
      _ballX += details.delta.dx / 100;
      _ballY += details.delta.dy / 100;
      
      // 限制范围
      _ballX = _ballX.clamp(-1.0, 1.0);
      _ballY = _ballY.clamp(-1.0, 1.0);
    });
  }
  
  void _resetBall() {
    setState(() {
      _ballX = 0;
      _ballY = 0;
    });
  }
  
  void _updateBallPosition() {
    // 模拟重力效果
    if (!_isBalancing) {
      setState(() {
        _ballX += (_targetX - _ballX) * 0.05;
        _ballY += (_targetY - _ballY) * 0.05;
      });
    }
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
    
    final record = TrainingRecord.create(
      childId: child.id,
      moduleId: 'balance_challenge',
      moduleName: '平衡挑战',
      trainingType: TrainingType.sensory,
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

/// 平衡台绘制器
class BalanceBoardPainter extends CustomPainter {
  final double ballX;
  final double ballY;
  final double targetX;
  final double targetY;
  final bool isBalancing;
  final int level;
  
  BalanceBoardPainter({
    required this.ballX,
    required this.ballY,
    required this.targetX,
    required this.targetY,
    required this.isBalancing,
    required this.level,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.4;
    
    // 绘制平衡台背景
    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), radius, bgPaint);
    
    // 绘制目标区域
    final targetPaint = Paint()
      ..color = isBalancing ? Colors.green.withOpacity(0.3) : Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final targetScreenX = centerX + targetX * radius * 0.6;
    final targetScreenY = centerY + targetY * radius * 0.6;
    
    canvas.drawCircle(
      Offset(targetScreenX, targetScreenY),
      radius * 0.2,
      targetPaint,
    );
    
    // 绘制同心圆刻度
    final linePaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (double r = radius * 0.3; r < radius; r += radius * 0.3) {
      canvas.drawCircle(Offset(centerX, centerY), r, linePaint);
    }
    
    // 绘制十字线
    canvas.drawLine(
      Offset(centerX - radius, centerY),
      Offset(centerX + radius, centerY),
      linePaint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - radius),
      Offset(centerX, centerY + radius),
      linePaint,
    );
    
    // 绘制小球
    final ballScreenX = centerX + ballX * radius * 0.8;
    final ballScreenY = centerY + ballY * radius * 0.8;
    
    final ballPaint = Paint()
      ..color = isBalancing ? Colors.red : Colors.blue
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(ballScreenX, ballScreenY),
      radius * 0.08,
      ballPaint,
    );
    
    // 绘制小球高光
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(ballScreenX - 5, ballScreenY - 5),
      radius * 0.03,
      highlightPaint,
    );
  }
  
  @override
  bool shouldRepaint(BalanceBoardPainter oldDelegate) {
    return oldDelegate.ballX != ballX ||
        oldDelegate.ballY != ballY ||
        oldDelegate.isBalancing != isBalancing;
  }
}
