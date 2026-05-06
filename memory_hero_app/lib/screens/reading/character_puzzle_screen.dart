import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import '../../providers/training_provider.dart';
import '../../providers/child_profile_provider.dart';
import '../../models/training_record.dart';

/// 汉字拼图 - 字形结构认知训练
class CharacterPuzzleScreen extends StatefulWidget {
  const CharacterPuzzleScreen({super.key});

  @override
  State<CharacterPuzzleScreen> createState() => _CharacterPuzzleScreenState();
}

class _CharacterPuzzleScreenState extends State<CharacterPuzzleScreen> {
  int _level = 1;
  int _score = 0;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isComplete = false;
  
  // 当前目标字
  String _targetCharacter = '';
  
  // 偏旁部首选项
  List<String> _radicalOptions = [];
  List<String> _selectedRadicals = [];
  
  // 汉字结构数据 (偏旁 + 部件 = 完整字)
  final List<Map<String, dynamic>> _characterData = [
    // Level 1: 简单合体字
    {'char': '明', 'parts': ['日', '月'], 'type': '左右'},
    {'char': '林', 'parts': ['木', '木'], 'type': '左右'},
    {'char': '从', 'parts': ['人', '人'], 'type': '左右'},
    {'char': '炎', 'parts': ['火', '火'], 'type': '上下'},
    {'char': '吕', 'parts': ['口', '口'], 'type': '上下'},
    
    // Level 2
    {'char': '好', 'parts': ['女', '子'], 'type': '左右'},
    {'char': '字', 'parts': ['宀', '子'], 'type': '上下'},
    {'char': '早', 'parts': ['日', '十'], 'type': '上下'},
    {'char': '尖', 'parts': ['小', '大'], 'type': '上下'},
    {'char': '男', 'parts': ['田', '力'], 'type': '上下'},
    
    // Level 3
    {'char': '想', 'parts': ['相', '心'], 'type': '上下'},
    {'char': '理', 'parts': ['王', '里'], 'type': '左右'},
    {'char': '河', 'parts': ['氵', '可'], 'type': '左右'},
    {'char': '树', 'parts': ['木', '对'], 'type': '左右'},
    {'char': '草', 'parts': ['艹', '早'], 'type': '上下'},
    
    // Level 4
    {'char': '湖', 'parts': ['氵', '胡'], 'type': '左右'},
    {'char': '海', 'parts': ['氵', '每'], 'type': '左右'},
    {'char': '请', 'parts': ['讠', '青'], 'type': '左右'},
    {'char': '话', 'parts': ['讠', '舌'], 'type': '左右'},
    {'char': '说', 'parts': ['讠', '兑'], 'type': '左右'},
    
    // Level 5
    {'char': '谢', 'parts': ['讠', '射'], 'type': '左右'},
    {'char': '妈', 'parts': ['女', '马'], 'type': '左右'},
    {'char': '奶', 'parts': ['女', '乃'], 'type': '左右'},
    {'char': '姐', 'parts': ['女', '且'], 'type': '左右'},
    {'char': '妹', 'parts': ['女', '未'], 'type': '左右'},
  ];
  
  Map<String, dynamic> get _currentData {
    final levelIndex = math.min(_level - 1, 4);
    final startIndex = levelIndex * 5;
    final index = startIndex + (_currentIndex % 5);
    return _characterData[math.min(index, _characterData.length - 1)];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('汉字拼图'),
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
                  _buildStatBox('结构', _currentData['type']),
                  _buildStatBox('进度', '${_currentIndex + 1}/5'),
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
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
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
          const Text('🧩', style: TextStyle(fontSize: 80)),
          SizedBox(height: 24.h),
          const Text(
            '汉字拼图',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          const Text(
            '将偏旁部首组合成完整的汉字\n认识汉字结构，加深理解',
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
        // 目标显示区
        Expanded(
          flex: 2,
          child: Container(
            margin: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppTheme.primaryColor, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '组合出这个字',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 16.h),
                Text(
                  _currentData['char'],
                  style: const TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '结构：${_currentData['type']}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        
        // 已选区域
        Container(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ..._selectedRadicals.map((radical) => _buildRadicalSlot(radical)),
              if (_selectedRadicals.length < _currentData['parts'].length)
                _buildEmptySlot(),
            ],
          ),
        ),
        
        // 选项区域
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _radicalOptions.length,
              itemBuilder: (context, index) {
                return _buildRadicalOption(_radicalOptions[index]);
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildRadicalSlot(String radical) {
    return Container(
      width: 80.w,
      height: 80.w,
      margin: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
        color: AppTheme.accentColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Text(
          radical,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptySlot() {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[400]!, width: 2, strokeAlign: BorderSide.strokeAlignInside),
      ),
      child: const Icon(Icons.add, size: 40, color: Colors.grey),
    );
  }
  
  Widget _buildRadicalOption(String radical) {
    final isSelected = _selectedRadicals.contains(radical);
    
    return GestureDetector(
      onTap: isSelected ? null : () => _selectRadical(radical),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? Colors.grey[400]! : AppTheme.accentColor,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            radical,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.grey[400] : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCompleteScreen() {
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
      _currentIndex = 0;
      _isComplete = false;
      _loadLevel();
    });
  }
  
  void _loadLevel() {
    final data = _currentData;
    setState(() {
      _targetCharacter = data['char'];
      _selectedRadicals = [];
      _radicalOptions = List.from(data['parts']);
      
      // 添加干扰项
      final distractors = ['木', '水', '火', '土', '金', '口', '手', '足'];
      while (_radicalOptions.length < 6) {
        final distractor = distractors[math.Random().nextInt(distractors.length)];
        if (!_radicalOptions.contains(distractor)) {
          _radicalOptions.add(distractor);
        }
      }
      
      // 打乱选项
      _radicalOptions.shuffle();
    });
  }
  
  void _selectRadical(String radical) {
    setState(() {
      _selectedRadicals.add(radical);
      _radicalOptions.remove(radical);
    });
    
    // 检查是否正确
    _checkAnswer();
  }
  
  void _checkAnswer() {
    final data = _currentData;
    final expectedParts = data['parts'] as List<String>;
    
    if (_selectedRadicals.length == expectedParts.length) {
      // 检查顺序是否正确（对于左右/上下结构）
      bool isCorrect = true;
      for (int i = 0; i < expectedParts.length; i++) {
        if (_selectedRadicals[i] != expectedParts[i]) {
          isCorrect = false;
          break;
        }
      }
      
      if (isCorrect) {
        // 正确
        setState(() {
          _score += 20;
          _isComplete = true;
        });
        _saveResult(true);
      } else {
        // 错误
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _selectedRadicals.clear();
              _loadLevel();
            });
            HapticFeedback.vibrate();
          }
        });
      }
    }
  }
  
  void _nextLevel() {
    setState(() {
      _currentIndex++;
      if (_currentIndex >= 5) {
        _currentIndex = 0;
        _level++;
      }
      _isComplete = false;
      _loadLevel();
    });
  }
  
  void _saveResult(bool completed) {
    final childProvider = context.read<ChildProfileProvider>();
    final trainingProvider = context.read<TrainingProvider>();
    final child = childProvider.currentChild;
    
    if (child == null) return;
    
    final record = TrainingRecord.create(
      childId: child.id,
      moduleId: 'character_puzzle',
      moduleName: '汉字拼图',
      trainingType: TrainingType.reading,
      difficulty: _level,
    ).copyWith(
      score: _score.clamp(0, 100),
      maxScore: 100,
      completed: completed,
      endTime: DateTime.now(),
      durationSeconds: 0,
    );
    
    trainingProvider.saveRecord(record);
  }
}
