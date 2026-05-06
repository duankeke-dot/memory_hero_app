/// 训练记录模型
class TrainingRecord {
  final String id;
  final String childId;
  final String moduleId;
  final String moduleName;
  final TrainingType trainingType;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final int score;
  final int maxScore;
  final int difficulty;
  final bool completed;
  final Map<String, dynamic>? details;
  
  TrainingRecord({
    required this.id,
    required this.childId,
    required this.moduleId,
    required this.moduleName,
    required this.trainingType,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.score,
    required this.maxScore,
    required this.difficulty,
    required this.completed,
    this.details,
  });
  
  double get accuracy => maxScore > 0 ? score / maxScore : 0;
  String get accuracyPercent => '${(accuracy * 100).toInt()}%';
  
  TrainingRecord copyWith({
    String? id,
    String? childId,
    String? moduleId,
    String? moduleName,
    TrainingType? trainingType,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    int? score,
    int? maxScore,
    int? difficulty,
    bool? completed,
    Map<String, dynamic>? details,
  }) {
    return TrainingRecord(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      moduleId: moduleId ?? this.moduleId,
      moduleName: moduleName ?? this.moduleName,
      trainingType: trainingType ?? this.trainingType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      difficulty: difficulty ?? this.difficulty,
      completed: completed ?? this.completed,
      details: details ?? this.details,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'moduleId': moduleId,
      'moduleName': moduleName,
      'trainingType': trainingType.value,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationSeconds': durationSeconds,
      'score': score,
      'maxScore': maxScore,
      'difficulty': difficulty,
      'completed': completed,
      'details': details,
    };
  }
  
  factory TrainingRecord.fromJson(Map<String, dynamic> json) {
    return TrainingRecord(
      id: json['id'] as String,
      childId: json['childId'] as String,
      moduleId: json['moduleId'] as String,
      moduleName: json['moduleName'] as String,
      trainingType: TrainingType.fromValue(json['trainingType'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      durationSeconds: json['durationSeconds'] as int,
      score: json['score'] as int,
      maxScore: json['maxScore'] as int,
      difficulty: json['difficulty'] as int,
      completed: json['completed'] as bool,
      details: json['details'] as Map<String, dynamic>?,
    );
  }
  
  /// 创建默认记录
  factory TrainingRecord.create({
    required String childId,
    required String moduleId,
    required String moduleName,
    required TrainingType trainingType,
    required int difficulty,
  }) {
    final now = DateTime.now();
    return TrainingRecord(
      id: now.millisecondsSinceEpoch.toString(),
      childId: childId,
      moduleId: moduleId,
      moduleName: moduleName,
      trainingType: trainingType,
      startTime: now,
      endTime: now,
      durationSeconds: 0,
      score: 0,
      maxScore: 100,
      difficulty: difficulty,
      completed: false,
    );
  }
}

/// 训练类型枚举
enum TrainingType {
  reading('reading', '阅读训练'),
  memory('memory', '记忆训练'),
  focus('focus', '专注力训练'),
  sensory('sensory', '感统训练');
  
  final String value;
  final String displayName;
  
  const TrainingType(this.value, this.displayName);
  
  static TrainingType fromValue(String value) {
    return TrainingType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TrainingType.reading,
    );
  }
}

/// 训练模块定义
class TrainingModule {
  final String id;
  final String name;
  final String description;
  final TrainingType type;
  final String icon;
  final Color color;
  final int minAge;
  final int maxAge;
  final List<String> targetAbilities;
  
  const TrainingModule({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    required this.color,
    required this.minAge,
    required this.maxAge,
    required this.targetAbilities,
  });
  
  /// 获取所有预定义模块
  static List<TrainingModule> get allModules {
    return [
      // 阅读训练模块
      const TrainingModule(
        id: 'sand_writing',
        name: '沙盘写字',
        description: '在虚拟沙盘上用手指写字，多感官学习',
        type: TrainingType.reading,
        icon: '📝',
        color: Color(0xFF4FC3F7),
        minAge: 6,
        maxAge: 12,
        targetAbilities: ['字形认知', '视觉追踪'],
      ),
      const TrainingModule(
        id: 'character_puzzle',
        name: '汉字拼图',
        description: '拖拽偏旁部首组合成汉字',
        type: TrainingType.reading,
        icon: '🧩',
        color: Color(0xFF66BB6A),
        minAge: 7,
        maxAge: 12,
        targetAbilities: ['字形认知', '结构理解'],
      ),
      const TrainingModule(
        id: 'colorful_reading',
        name: '彩色阅读',
        description: '可调节颜色和字距的阅读训练',
        type: TrainingType.reading,
        icon: '📖',
        color: Color(0xFFFFB74D),
        minAge: 7,
        maxAge: 12,
        targetAbilities: ['朗读流畅', '视觉追踪'],
      ),
      const TrainingModule(
        id: 'reading_challenge',
        name: '朗读挑战',
        description: 'AI 评分的朗读练习',
        type: TrainingType.reading,
        icon: '🎤',
        color: Color(0xFFAB47BC),
        minAge: 8,
        maxAge: 12,
        targetAbilities: ['朗读流畅', '语音意识'],
      ),
      
      // 记忆训练模块
      const TrainingModule(
        id: 'number_sequence',
        name: '数字接龙',
        description: '复述逐渐增长的数字序列',
        type: TrainingType.memory,
        icon: '🔢',
        color: Color(0xFF42A5F5),
        minAge: 6,
        maxAge: 12,
        targetAbilities: ['工作记忆', '听觉记忆'],
      ),
      const TrainingModule(
        id: 'memory_flip',
        name: '记忆翻牌',
        description: '配对卡片位置记忆游戏',
        type: TrainingType.memory,
        icon: '🃏',
        color: Color(0xFFEF5350),
        minAge: 6,
        maxAge: 12,
        targetAbilities: ['视觉记忆', '工作记忆'],
      ),
      const TrainingModule(
        id: 'n_back',
        name: 'N-Back 挑战',
        description: '记住 N 步前的图案位置',
        type: TrainingType.memory,
        icon: '🧠',
        color: Color(0xFF81C784),
        minAge: 8,
        maxAge: 12,
        targetAbilities: ['工作记忆', '注意力'],
      ),
      const TrainingModule(
        id: 'story_recall',
        name: '故事回忆',
        description: '听故事后回答问题',
        type: TrainingType.memory,
        icon: '📚',
        color: Color(0xFFFFCA28),
        minAge: 7,
        maxAge: 12,
        targetAbilities: ['情景记忆', '听觉记忆'],
      ),
      
      // 专注力训练模块
      const TrainingModule(
        id: 'schulte_grid',
        name: '舒尔特方格',
        description: '快速点击有序数字',
        type: TrainingType.focus,
        icon: '🎯',
        color: Color(0xFF26C6DA),
        minAge: 7,
        maxAge: 12,
        targetAbilities: ['视觉注意力', '反应速度'],
      ),
      const TrainingModule(
        id: 'ball_tracking',
        name: '追踪小球',
        description: '跟随移动的目标',
        type: TrainingType.focus,
        icon: '⚽',
        color: Color(0xFFFF7043),
        minAge: 6,
        maxAge: 12,
        targetAbilities: ['视觉追踪', '持续注意'],
      ),
      const TrainingModule(
        id: 'find_difference',
        name: '找不同',
        description: '找出两幅图的差异',
        type: TrainingType.focus,
        icon: '🔍',
        color: Color(0xFFBA68C8),
        minAge: 6,
        maxAge: 12,
        targetAbilities: ['视觉辨别', '持续注意'],
      ),
    ];
  }
  
  /// 根据类型筛选模块
  static List<TrainingModule> getByType(TrainingType type) {
    return allModules.where((m) => m.type == type).toList();
  }
  
  /// 根据 ID 获取模块
  static TrainingModule? getById(String id) {
    try {
      return allModules.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }
}
