import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import '../../providers/training_provider.dart';
import '../../providers/child_profile_provider.dart';
import '../../models/training_record.dart';

/// 故事回忆 - 情景记忆训练
class StoryRecallScreen extends StatefulWidget {
  const StoryRecallScreen({super.key});

  @override
  State<StoryRecallScreen> createState() => _StoryRecallScreenState();
}

class _StoryRecallScreenState extends State<StoryRecallScreen> {
  int _level = 1;
  int _score = 0;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isPlayingAudio = false;
  bool _isAnswering = false;
  bool _isComplete = false;
  
  // 当前问题索引
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  
  // 故事数据
  final List<Map<String, dynamic>> _stories = [
    // Level 1 - 简单故事
    {
      'story': '小明今天去公园玩。他看到了很多花，有红色的、黄色的、还有紫色的。他还看到了小鸟在树上唱歌。',
      'questions': [
        {'q': '小明去了哪里？', 'options': ['学校', '公园', '家'], 'answer': 1},
        {'q': '花有哪些颜色？', 'options': ['红黄紫', '红蓝绿', '黄绿紫'], 'answer': 0},
        {'q': '小鸟在做什么？', 'options': ['飞', '唱歌', '睡觉'], 'answer': 1},
      ],
    },
    {
      'story': '妈妈买了一个大西瓜回家。西瓜是绿色的，里面是红色的，还有很多黑色的籽。小明吃得很开心。',
      'questions': [
        {'q': '妈妈买了什么？', 'options': ['苹果', '西瓜', '香蕉'], 'answer': 1},
        {'q': '西瓜外面是什么颜色？', 'options': ['红色', '绿色', '黄色'], 'answer': 1},
        {'q': '西瓜籽是什么颜色？', 'options': ['黑色', '白色', '红色'], 'answer': 0},
      ],
    },
    // Level 2
    {
      'story': '春天来了，天气变暖了。小燕子从南方飞回来了。它们在屋檐下筑巢，生下了小宝宝。每天，燕子妈妈都会出去找虫子喂小燕子。',
      'questions': [
        {'q': '什么季节来了？', 'options': ['夏天', '春天', '秋天'], 'answer': 1},
        {'q': '小燕子从哪里飞回来？', 'options': ['北方', '南方', '西方'], 'answer': 1},
        {'q': '燕子妈妈喂小燕子吃什么？', 'options': ['米', '虫子', '水果'], 'answer': 1},
      ],
    },
    {
      'story': '星期天，爸爸带我去钓鱼。我们来到小河边，爸爸帮我装上鱼饵，然后把鱼钩甩进水里。等了好久，终于有一条小鱼上钩了！',
      'questions': [
        {'q': '这是星期几？', 'options': ['星期六', '星期天', '星期一'], 'answer': 1},
        {'q': '我们去干什么？', 'options': ['游泳', '钓鱼', '划船'], 'answer': 1},
        {'q': '最后钓到了什么？', 'options': ['大鱼', '小鱼', '没钓到'], 'answer': 1},
      ],
    },
    // Level 3
    {
      'story': '小红今天过生日。妈妈给她买了一个漂亮的生日蛋糕，蛋糕上有七根蜡烛，因为小红七岁了。爸爸送给她一个洋娃娃作为生日礼物。小红很开心。',
      'questions': [
        {'q': '今天是谁的生日？', 'options': ['妈妈', '小红', '爸爸'], 'answer': 1},
        {'q': '小红几岁了？', 'options': ['六岁', '七岁', '八岁'], 'answer': 1},
        {'q': '爸爸送了什么礼物？', 'options': ['书', '洋娃娃', '玩具车'], 'answer': 1},
      ],
    },
    // Level 4
    {
      'story': '学校组织春游，我们去了动物园。首先看到了大象，它的鼻子很长。然后看到了长颈鹿，它的脖子很高。最后还看了猴子表演，猴子们很聪明，会骑自行车。',
      'questions': [
        {'q': '学校组织去哪里？', 'options': ['公园', '动物园', '博物馆'], 'answer': 1},
        {'q': '大象的什么部位很长？', 'options': ['耳朵', '鼻子', '尾巴'], 'answer': 1},
        {'q': '猴子会表演什么？', 'options': ['跳舞', '骑自行车', '唱歌'], 'answer': 1},
      ],
    },
    // Level 5
    {
      'story': '中秋节到了，全家人围坐在院子里赏月。月亮又圆又亮，像一个白玉盘。奶奶给我们讲了嫦娥奔月的故事。我们一边吃月饼，一边听故事，度过了一个美好的夜晚。',
      'questions': [
        {'q': '这是什么节日？', 'options': ['春节', '中秋节', '端午节'], 'answer': 1},
        {'q': '月亮像什么？', 'options': ['香蕉', '白玉盘', '小船'], 'answer': 1},
        {'q': '奶奶讲了什么故事？', 'options': ['嫦娥奔月', '后羿射日', '牛郎织女'], 'answer': 0},
      ],
    },
  ];
  
  Map<String, dynamic> get _currentStory {
    final index = math.min((_level - 1) * 2 + _currentIndex, _stories.length - 1);
    return _stories[index];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('故事回忆'),
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
                  _buildStatBox('进度', '${_currentIndex + 1}/2'),
                  _buildStatBox('正确', '$_correctAnswers/3'),
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
          const Text('📚', style: TextStyle(fontSize: 80)),
          SizedBox(height: 24.h),
          const Text(
            '故事回忆',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          const Text(
            '听故事，然后回答问题\n锻炼记忆力和理解力',
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
    
    if (_isAnswering) {
      return _buildQuestionArea();
    }
    
    return _buildStoryArea();
  }
  
  Widget _buildStoryArea() {
    final story = _currentStory['story'] as String;
    
    return Column(
      children: [
        // 故事显示区
        Expanded(
          child: Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  '请仔细阅读下面的故事',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      story,
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 控制按钮
        Padding(
          padding: EdgeInsets.all(24.w),
          child: ElevatedButton(
            onPressed: _startQuestions,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text('我记住了，开始答题', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuestionArea() {
    final story = _currentStory;
    final questions = story['questions'] as List<dynamic>;
    
    if (_currentQuestionIndex >= questions.length) {
      _finishStory();
      return const SizedBox();
    }
    
    final question = questions[_currentQuestionIndex] as Map<String, dynamic>;
    
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // 进度指示
          Row(
            children: [
              const Text('问题 ', style: TextStyle(fontSize: 16)),
              Text(
                '${_currentQuestionIndex + 1}/${questions.length}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          
          // 问题
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              question['q'] as String,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 32.h),
          
          // 选项
          ...List.generate(question['options'].length, (index) {
            final option = question['options'][index] as String;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _answerQuestion(index),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildCompleteScreen() {
    final accuracy = (_correctAnswers / 3 * 100).toInt();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            accuracy >= 100 ? '🏆' : accuracy >= 67 ? '🌟' : '💪',
            style: const TextStyle(fontSize: 80),
          ),
          SizedBox(height: 24.h),
          Text(
            accuracy >= 100 ? '完美！' : accuracy >= 67 ? '很棒！' : '继续加油！',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Text(
            '答对 $_correctAnswers/3 题',
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
      _currentQuestionIndex = 0;
      _correctAnswers = 0;
    });
  }
  
  void _startQuestions() {
    setState(() {
      _isAnswering = true;
      _currentQuestionIndex = 0;
      _correctAnswers = 0;
    });
  }
  
  void _answerQuestion(int answerIndex) {
    final story = _currentStory;
    final questions = story['questions'] as List<dynamic>;
    final question = questions[_currentQuestionIndex] as Map<String, dynamic>;
    final correctAnswer = question['answer'] as int;
    
    if (answerIndex == correctAnswer) {
      setState(() {
        _correctAnswers++;
        _score += 10;
      });
    }
    
    setState(() {
      _currentQuestionIndex++;
    });
  }
  
  void _finishStory() {
    setState(() {
      _currentIndex++;
      _isAnswering = false;
      
      if (_currentIndex >= 2) {
        _isComplete = true;
        _saveResult();
      }
    });
  }
  
  void _nextLevel() {
    setState(() {
      if (_currentIndex >= 2) {
        _level++;
        _currentIndex = 0;
      }
      _isComplete = false;
      _correctAnswers = 0;
    });
    _startGame();
  }
  
  void _saveResult() {
    final childProvider = context.read<ChildProfileProvider>();
    final trainingProvider = context.read<TrainingProvider>();
    final child = childProvider.currentChild;
    
    if (child == null) return;
    
    final accuracy = (_correctAnswers / 3 * 100).toInt();
    
    final record = TrainingRecord.create(
      childId: child.id,
      moduleId: 'story_recall',
      moduleName: '故事回忆',
      trainingType: TrainingType.memory,
      difficulty: _level,
    ).copyWith(
      score: accuracy.clamp(0, 100),
      maxScore: 100,
      completed: true,
      endTime: DateTime.now(),
      durationSeconds: 0,
      details: {'correct': _correctAnswers, 'total': 3},
    );
    
    trainingProvider.saveRecord(record);
  }
}
