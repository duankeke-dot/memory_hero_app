import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

import '../../providers/training_provider.dart';
import '../../providers/child_profile_provider.dart';
import '../../models/training_record.dart';

/// 数字接龙 - 工作记忆训练
class NumberSequenceScreen extends StatefulWidget {
  const NumberSequenceScreen({super.key});

  @override
  State<NumberSequenceScreen> createState() => _NumberSequenceScreenState();
}

class _NumberSequenceScreenState extends State<NumberSequenceScreen> with SingleTickerProviderStateMixin {
  int _level = 1;
  int _score = 0;
  int _maxScore = 100;
  List<int> _currentSequence = [];
  List<int> _userSequence = [];
  bool _isPlaying = false;
  bool _isShowingSequence = false;
  String _gameState = 'ready'; // ready, showing, input, success, fail
  int _correctCount = 0;
  int _totalRounds = 5;
  
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _startGame() {
    setState(() {
      _level = 1;
      _score = 0;
      _correctCount = 0;
      _gameState = 'showing';
      _isPlaying = true;
      _generateSequence();
    });
    _showSequence();
  }
  
  void _generateSequence() {
    final random = Random();
    final sequenceLength = 2 + _level; // 每关增加长度
    _currentSequence = List.generate(
      sequenceLength,
      (_) => random.nextInt(10),
    );
    _userSequence = [];
  }
  
  Future<void> _showSequence() async {
    setState(() {
      _isShowingSequence = true;
    });
    
    // 逐个显示数字
    for (int i = 0; i < _currentSequence.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      
      // 高亮显示当前数字
      setState(() {});
      
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    setState(() {
      _isShowingSequence = false;
      _gameState = 'input';
    });
  }
  
  void _onNumberTap(int number) {
    if (_gameState != 'input') return;
    
    setState(() {
      _userSequence.add(number);
    });
    
    // 检查是否正确
    final index = _userSequence.length - 1;
    if (_userSequence[index] != _currentSequence[index]) {
      // 错误
      _gameFail();
      return;
    }
    
    // 检查是否完成本轮
    if (_userSequence.length == _currentSequence.length) {
      _roundSuccess();
    }
  }
  
  void _roundSuccess() {
    _correctCount++;
    _score += 20;
    
    if (_correctCount >= _totalRounds) {
      _gameSuccess();
    } else {
      _level++;
      setState(() {
        _gameState = 'showing';
      });
      _generateSequence();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _showSequence();
      });
    }
  }
  
  void _gameSuccess() {
    setState(() {
      _gameState = 'success';
      _isPlaying = false;
    });
    _saveResult(true);
  }
  
  void _gameFail() {
    setState(() {
      _gameState = 'fail';
      _isPlaying = false;
    });
    _saveResult(false);
  }
  
  void _saveResult(bool completed) {
    final childProvider = context.read<ChildProfileProvider>();
    final trainingProvider = context.read<TrainingProvider>();
    final child = childProvider.currentChild;
    
    if (child == null) return;
    
    final record = TrainingRecord.create(
      childId: child.id,
      moduleId: 'number_sequence',
      moduleName: '数字接龙',
      trainingType: TrainingType.memory,
      difficulty: _level,
    ).copyWith(
      score: _score,
      maxScore: _maxScore,
      completed: completed,
      endTime: DateTime.now(),
      durationSeconds: 0, // TODO: 记录实际时长
    );
    
    trainingProvider.saveRecord(record);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数字接龙'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Text(
                '得分：$_score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 进度指示
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '关卡 $_level',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  Text(
                    '进度：$_correctCount/$_totalRounds',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            
            // 游戏区域
            Expanded(
              child: _buildGameArea(),
            ),
            
            // 数字键盘
            if (_gameState == 'input') _buildNumberPad(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGameArea() {
    switch (_gameState) {
      case 'ready':
        return _buildReadyState();
      case 'showing':
      case 'input':
        return _buildPlayState();
      case 'success':
        return _buildSuccessState();
      case 'fail':
        return _buildFailState();
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildReadyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🧠 数字接龙',
            style: TextStyle(fontSize: 32),
          ),
          SizedBox(height: 24.h),
          const Text(
            '仔细观察数字序列\n然后按顺序重复出来',
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
  
  Widget _buildPlayState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isShowingSequence)
            const Text(
              '请记住这些数字...',
              style: TextStyle(fontSize: 20),
            )
          else
            const Text(
              '请按顺序点击数字',
              style: TextStyle(fontSize: 20),
            ),
          SizedBox(height: 48.h),
          // 显示序列或用户输入
          Wrap(
            spacing: 16.w,
            runSpacing: 16.h,
            alignment: WrapAlignment.center,
            children: _isShowingSequence
                ? _currentSequence.map((n) => _buildNumberBubble(n, true)).toList()
                : _userSequence.map((n) => _buildNumberBubble(n, false)).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNumberBubble(int number, bool isSequence) {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        color: isSequence ? AppTheme.primaryColor : AppTheme.accentColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Widget _buildNumberPad() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final number = index + 1;
          return GestureDetector(
            onTap: () => _onNumberTap(number),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppTheme.primaryColor),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSuccessState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 80)),
          SizedBox(height: 24.h),
          const Text(
            '太棒了！',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Text(
            '得分：$_score',
            style: const TextStyle(fontSize: 24),
          ),
          SizedBox(height: 48.h),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text('继续', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFailState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😔', style: TextStyle(fontSize: 80)),
          SizedBox(height: 24.h),
          const Text(
            '再接再厉！',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
                onPressed: () => setState(() {
                  _gameState = 'ready';
                }),
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
}
