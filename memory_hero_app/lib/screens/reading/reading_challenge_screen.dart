import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import '../../providers/training_provider.dart';
import '../../providers/child_profile_provider.dart';
import '../../models/training_record.dart';

/// 朗读挑战 - AI 评分的朗读练习
class ReadingChallengeScreen extends StatefulWidget {
  const ReadingChallengeScreen({super.key});

  @override
  State<ReadingChallengeScreen> createState() => _ReadingChallengeScreenState();
}

class _ReadingChallengeScreenState extends State<ReadingChallengeScreen> {
  int _level = 1;
  int _score = 0;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isRecording = false;
  bool _isComplete = false;
  
  // 朗读材料
  final List<Map<String, dynamic>> _challenges = [
    // Level 1 - 单字
    {'type': 'word', 'text': '山', 'pinyin': 'shān'},
    {'type': 'word', 'text': '水', 'pinyin': 'shuǐ'},
    {'type': 'word', 'text': '火', 'pinyin': 'huǒ'},
    {'type': 'word', 'text': '土', 'pinyin': 'tǔ'},
    {'type': 'word', 'text': '木', 'pinyin': 'mù'},
    
    // Level 2 - 词语
    {'type': 'word', 'text': '春天', 'pinyin': 'chūn tiān'},
    {'type': 'word', 'text': '夏天', 'pinyin': 'xià tiān'},
    {'type': 'word', 'text': '秋天', 'pinyin': 'qiū tiān'},
    {'type': 'word', 'text': '冬天', 'pinyin': 'dōng tiān'},
    {'type': 'word', 'text': '学校', 'pinyin': 'xué xiào'},
    
    // Level 3 - 短语
    {'type': 'phrase', 'text': '太阳出来了', 'pinyin': 'tài yáng chū lái le'},
    {'type': 'phrase', 'text': '小鸟在唱歌', 'pinyin': 'xiǎo niǎo zài chàng gē'},
    {'type': 'phrase', 'text': '花儿开了', 'pinyin': 'huā er kāi le'},
    {'type': 'phrase', 'text': '草儿绿了', 'pinyin': 'cǎo er lǜ le'},
    {'type': 'phrase', 'text': '我爱读书', 'pinyin': 'wǒ ài dú shū'},
    
    // Level 4 - 句子
    {'type': 'sentence', 'text': '春天来了，花儿开了，草儿绿了。', 'pinyin': 'chūn tiān lái le...'},
    {'type': 'sentence', 'text': '我爱我的祖国，我爱我的家。', 'pinyin': 'wǒ ài wǒ de...'},
    {'type': 'sentence', 'text': '好好学习，天天向上。', 'pinyin': 'hǎo hǎo xué xí...'},
    {'type': 'sentence', 'text': '书籍是人类进步的阶梯。', 'pinyin': 'shū jí shì...'},
    {'type': 'sentence', 'text': '一分耕耘，一分收获。', 'pinyin': 'yī fēn gēng yún...'},
    
    // Level 5 - 段落
    {'type': 'paragraph', 'text': '清晨，太阳从东方升起，金色的阳光洒满大地。鸟儿在枝头欢快地歌唱，花儿在微风中轻轻摇摆。', 'pinyin': 'qīng chén...'},
  ];
  
  Map<String, dynamic> get _currentChallenge {
    final levelIndex = math.min(_level - 1, 4);
    final startIndex = levelIndex * 5;
    final index = startIndex + (_currentIndex % 5);
    return _challenges[math.min(index, _challenges.length - 1)];
  }
  
  // 模拟评分
  int _simulateScore() {
    final random = math.Random();
    // 基础分 60-80，加上随机波动
    return 60 + random.nextInt(40);
  }
  
  @override
  Widget build(BuildContext context) {
    final challenge = _currentChallenge;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('朗读挑战'),
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
                  _buildStatBox('类型', _getTypeName(challenge['type'])),
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
  
  String _getTypeName(String type) {
    switch (type) {
      case 'word': return '单字';
      case 'phrase': return '短语';
      case 'sentence': return '句子';
      case 'paragraph': return '段落';
      default: return type;
    }
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
          const Text('🎤', style: TextStyle(fontSize: 80)),
          SizedBox(height: 24.h),
          const Text(
            '朗读挑战',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          const Text(
            '大声朗读屏幕上的内容\nAI 会为你评分',
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
    
    final challenge = _currentChallenge;
    
    return Column(
      children: [
        // 提示区域
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.infoColor.withOpacity(0.1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              Text(
                '请朗读${_getTypeName(challenge['type'])}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 16.h),
              Text(
                challenge['text'],
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                challenge['pinyin'],
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        // 录音状态
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isRecording) ...[
                  const Text(
                    '正在录音...',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  SizedBox(height: 24.h),
                  _buildRecordingAnimation(),
                ] else ...[
                  const Text(
                    '点击下方按钮开始朗读',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // 控制按钮
        Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // 录音按钮
              GestureDetector(
                onTap: _toggleRecording,
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: _isRecording ? AppTheme.errorColor : AppTheme.infoColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? AppTheme.errorColor : AppTheme.infoColor).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.mic : Icons.mic_none,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                _isRecording ? '再次点击停止' : '点击开始朗读',
                style: TextStyle(color: Colors.grey[600]),
              ),
              
              SizedBox(height: 24.h),
              
              // 下一题按钮
              if (!_isRecording && _isComplete)
                ElevatedButton(
                  onPressed: _nextChallenge,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    child: Text('继续下一题'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecordingAnimation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          width: 8.w,
          height: 40.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppTheme.infoColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
  
  Widget _buildCompleteScreen() {
    final challenge = _currentChallenge;
    final score = _simulateScore();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score >= 80 ? '🌟' : score >= 60 ? '👍' : '💪',
            style: const TextStyle(fontSize: 80),
          ),
          SizedBox(height: 24.h),
          Text(
            score >= 80 ? '太棒了！' : score >= 60 ? '不错哦！' : '继续加油！',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Text(
            '得分：$score',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.infoColor),
          ),
          SizedBox(height: 16.h),
          Text(
            '准确度：${score}%',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 48.h),
          ElevatedButton(
            onPressed: _nextChallenge,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text('继续', style: TextStyle(fontSize: 18)),
            ),
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
      _isRecording = false;
    });
  }
  
  void _toggleRecording() {
    if (_isRecording) {
      // 停止录音，显示评分
      setState(() {
        _isRecording = false;
        _isComplete = true;
        _score += _simulateScore() ~/ 5;
      });
    } else {
      // 开始录音
      setState(() {
        _isRecording = true;
      });
    }
  }
  
  void _nextChallenge() {
    setState(() {
      _currentIndex++;
      if (_currentIndex >= 5) {
        _currentIndex = 0;
        _level++;
      }
      _isComplete = false;
      _isRecording = false;
    });
    
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
      moduleId: 'reading_challenge',
      moduleName: '朗读挑战',
      trainingType: TrainingType.reading,
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
