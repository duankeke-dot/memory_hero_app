import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers/training_provider.dart';
import '../../providers/child_profile_provider.dart';
import '../../models/training_record.dart';

/// 彩色阅读 - 可调节的阅读训练
class ColorfulReadingScreen extends StatefulWidget {
  const ColorfulReadingScreen({super.key});

  @override
  State<ColorfulReadingScreen> createState() => _ColorfulReadingScreenState();
}

class _ColorfulReadingScreenState extends State<ColorfulReadingScreen> {
  int _level = 1;
  int _score = 0;
  bool _isPlaying = false;
  bool _isReading = false;
  
  // 阅读设置
  double _fontSize = 24.0;
  double _lineSpacing = 1.5;
  double _letterSpacing = 0.0;
  Color _backgroundColor = const Color(0xFFFFF8DC); // 米黄色
  Color _textColor = Colors.black;
  
  // 阅读材料
  final List<String> _readingPassages = [
    // Level 1
    '春天来了。花儿开了。草儿绿了。小鸟在树上唱歌。',
    '夏天到了。天气很热。我们去游泳。吃冰淇淋。',
    '秋天来了。树叶黄了。果实熟了。农民伯伯笑了。',
    '冬天来了。下雪了。我们堆雪人。打雪仗。',
    '我爱我的家。家里有爸爸。家里有妈妈。还有我。',
    
    // Level 2
    '清晨，太阳从东方升起。金色的阳光洒满大地。鸟儿在枝头欢快地歌唱。',
    '放学后，我和小伙伴们一起去公园玩。我们踢足球，放风筝，玩得很开心。',
    '妈妈做的饭真好吃。有红烧肉，有清蒸鱼，还有我最爱吃的西红柿炒鸡蛋。',
    '周末，爸爸带我去动物园。我看到了大象，长颈鹿，还有可爱的熊猫。',
    '晚上，我坐在窗前看书。窗外的月亮圆圆的，星星一闪一闪的。',
    
    // Level 3
    '我的学校很美丽。教学楼前面有一个大花坛，里面种着各种各样的花。操场很大，我们在那里上体育课。',
    '春天是播种的季节。农民伯伯在田里辛勤地劳作，种下希望的种子。他们期待着秋天的收获。',
    '读书使人进步。书籍是人类的好朋友。通过读书，我们可以学到很多知识，开阔视野。',
    '帮助别人是一种快乐。当别人遇到困难时，我们应该伸出援手。赠人玫瑰，手有余香。',
    '保护环境，人人有责。我们要爱护花草树木，不乱扔垃圾。让地球变得更加美丽。',
  ];
  
  String get _currentPassage {
    final index = (_level - 1) % _readingPassages.length;
    return _readingPassages[index];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('彩色阅读'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
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
                  _buildStatBox('字数', '${_currentPassage.length}'),
                  _buildStatBox('时长', '0:00'),
                ],
              ),
            ),
            
            // 游戏区域
            Expanded(
              child: _isPlaying ? _buildReadingArea() : _buildStartScreen(),
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
          const Text('📖', style: TextStyle(fontSize: 80)),
          SizedBox(height: 24.h),
          const Text(
            '彩色阅读',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          const Text(
            '可调节字体和颜色的阅读训练\n找到最适合你的阅读方式',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 48.h),
          ElevatedButton(
            onPressed: _startGame,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text('开始阅读', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReadingArea() {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _backgroundColor,
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
          // 阅读内容
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Text(
                _currentPassage,
                style: TextStyle(
                  fontSize: _fontSize,
                  height: _lineSpacing,
                  letterSpacing: _letterSpacing,
                  color: _textColor,
                  fontWeight: FontWeight.w500,
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
                    onPressed: _isReading ? _stopReading : null,
                    icon: Icon(_isReading ? Icons.pause : Icons.play_arrow),
                    label: Text(_isReading ? '暂停' : '开始'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _completeReading,
                    icon: const Icon(Icons.check),
                    label: const Text('完成'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isReading = true;
      _level = 1;
      _score = 0;
    });
  }
  
  void _stopReading() {
    setState(() {
      _isReading = false;
    });
  }
  
  void _completeReading() {
    setState(() {
      _isPlaying = false;
      _isReading = false;
      _score += 20;
    });
    _saveResult();
    
    // 显示完成对话框
    _showCompleteDialog();
  }
  
  void _showCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('阅读完成！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 50)),
            SizedBox(height: 16.h),
            Text('得分：$_score'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextLevel();
            },
            child: const Text('继续'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
  
  void _nextLevel() {
    setState(() {
      _level++;
    });
    _startGame();
  }
  
  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        height: 400.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '阅读设置',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24.h),
            
            // 字体大小
            const Text('字体大小'),
            Slider(
              value: _fontSize,
              min: 16,
              max: 36,
              divisions: 10,
              label: _fontSize.toStringAsFixed(0),
              onChanged: (value) => setState(() => _fontSize = value),
            ),
            
            // 行间距
            const Text('行间距'),
            Slider(
              value: _lineSpacing,
              min: 1.0,
              max: 2.5,
              divisions: 15,
              label: _lineSpacing.toStringAsFixed(1),
              onChanged: (value) => setState(() => _lineSpacing = value),
            ),
            
            // 字间距
            const Text('字间距'),
            Slider(
              value: _letterSpacing,
              min: 0,
              max: 5,
              divisions: 10,
              label: _letterSpacing.toStringAsFixed(1),
              onChanged: (value) => setState(() => _letterSpacing = value),
            ),
            
            // 背景颜色
            const Text('背景颜色'),
            Wrap(
              spacing: 8,
              children: [
                _buildColorOption(const Color(0xFFFFF8DC), '米黄'),
                _buildColorOption(const Color(0xFFE8F4F8), '浅蓝'),
                _buildColorOption(const Color(0xFFE8F5E9), '浅绿'),
                _buildColorOption(Colors.white, '白色'),
                _buildColorOption(const Color(0xFF2D3748), '深色'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorOption(Color color, String label) {
    final isSelected = _backgroundColor == color;
    return GestureDetector(
      onTap: () => setState(() => _backgroundColor = color),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color == const Color(0xFF2D3748) ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  void _saveResult() {
    final childProvider = context.read<ChildProfileProvider>();
    final trainingProvider = context.read<TrainingProvider>();
    final child = childProvider.currentChild;
    
    if (child == null) return;
    
    final record = TrainingRecord.create(
      childId: child.id,
      moduleId: 'colorful_reading',
      moduleName: '彩色阅读',
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
