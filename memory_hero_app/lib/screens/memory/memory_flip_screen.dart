import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

import '../../providers/training_provider.dart';
import '../../providers/child_profile_provider.dart';
import '../../models/training_record.dart';

/// 记忆翻牌 - 视觉记忆训练
class MemoryFlipScreen extends StatefulWidget {
  const MemoryFlipScreen({super.key});

  @override
  State<MemoryFlipScreen> createState() => _MemoryFlipScreenState();
}

class _MemoryFlipScreenState extends State<MemoryFlipScreen> {
  int _level = 1;
  int _score = 0;
  int _moves = 0;
  int _matchedPairs = 0;
  int _totalPairs = 6; // 3x4 网格
  
  List<CardItem> _cards = [];
  int? _firstCardIndex;
  int? _secondCardIndex;
  bool _isProcessing = false;
  bool _gameStarted = false;
  bool _gameComplete = false;
  
  final List<String> _emojis = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮'];

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }
  
  void _initializeCards() {
    final random = Random();
    final selectedEmojis = _emojis.sublist(0, _totalPairs);
    final cardEmojis = [...selectedEmojis, ...selectedEmojis];
    cardEmojis.shuffle(random);
    
    _cards = cardEmojis.map((emoji) => CardItem(emoji: emoji, isFlipped: false, isMatched: false)).toList();
  }
  
  void _startGame() {
    setState(() {
      _level = 1;
      _score = 0;
      _moves = 0;
      _matchedPairs = 0;
      _gameStarted = true;
      _gameComplete = false;
      _firstCardIndex = null;
      _secondCardIndex = null;
      _isProcessing = false;
      _initializeCards();
    });
  }
  
  void _onCardTap(int index) {
    if (_isProcessing || !_gameStarted || _gameComplete) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;
    
    setState(() {
      _cards[index].isFlipped = true;
    });
    
    if (_firstCardIndex == null) {
      // 第一张牌
      _firstCardIndex = index;
    } else if (_secondCardIndex == null) {
      // 第二张牌
      _secondCardIndex = index;
      _moves++;
      _checkMatch();
    }
  }
  
  void _checkMatch() {
    if (_firstCardIndex == null || _secondCardIndex == null) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    final firstCard = _cards[_firstCardIndex!];
    final secondCard = _cards[_secondCardIndex!];
    
    if (firstCard.emoji == secondCard.emoji) {
      // 匹配成功
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          firstCard.isMatched = true;
          secondCard.isMatched = true;
          _matchedPairs++;
          _score += 10;
        });
        
        if (_matchedPairs >= _totalPairs) {
          _gameComplete = true;
          _saveResult(true);
        }
        
        _firstCardIndex = null;
        _secondCardIndex = null;
        _isProcessing = false;
      });
    } else {
      // 匹配失败
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          firstCard.isFlipped = false;
          secondCard.isFlipped = false;
        });
        
        _firstCardIndex = null;
        _secondCardIndex = null;
        _isProcessing = false;
      });
    }
  }
  
  void _saveResult(bool completed) {
    final childProvider = context.read<ChildProfileProvider>();
    final trainingProvider = context.read<TrainingProvider>();
    final child = childProvider.currentChild;
    
    if (child == null) return;
    
    // 计算得分（考虑步数）
    final perfectMoves = _totalPairs * 2;
    final efficiency = perfectMoves / _moves;
    final finalScore = (efficiency * 50).clamp(0, 100).toInt();
    
    final record = TrainingRecord.create(
      childId: child.id,
      moduleId: 'memory_flip',
      moduleName: '记忆翻牌',
      trainingType: TrainingType.memory,
      difficulty: _level,
    ).copyWith(
      score: finalScore,
      maxScore: 100,
      completed: completed,
      endTime: DateTime.now(),
      durationSeconds: 0,
      details: {'moves': _moves},
    );
    
    trainingProvider.saveRecord(record);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记忆翻牌'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Text(
                '步数：$_moves',
                style: const TextStyle(fontSize: 16),
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
                  _buildStatBox('得分', '$_score'),
                  _buildStatBox('配对', '$_matchedPairs/$_totalPairs'),
                ],
              ),
            ),
            
            // 游戏区域
            Expanded(
              child: _gameStarted
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
          const Text('🃏', style: TextStyle(fontSize: 80)),
          SizedBox(height: 24.h),
          const Text(
            '记忆翻牌',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          const Text(
            '找出所有配对的卡片',
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
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          return _buildCard(index);
        },
      ),
    );
  }
  
  Widget _buildCard(int index) {
    final card = _cards[index];
    
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.isFlipped || card.isMatched ? Colors.white : AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: card.isFlipped || card.isMatched
              ? Text(
                  card.emoji,
                  style: const TextStyle(fontSize: 40),
                )
              : const Icon(
                  Icons.question_mark,
                  color: Colors.white,
                  size: 40,
                ),
        ),
      ),
    );
  }
}

class CardItem {
  final String emoji;
  bool isFlipped;
  bool isMatched;
  
  CardItem({
    required this.emoji,
    required this.isFlipped,
    required this.isMatched,
  });
}
