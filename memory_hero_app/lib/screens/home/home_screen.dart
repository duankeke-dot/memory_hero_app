import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

import '../../config/routes.dart';
import '../../providers/child_profile_provider.dart';
import '../../providers/training_provider.dart';
import '../../models/training_record.dart';
import '../parent/parent_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const _HomeTab(),
    const ParentDashboardScreen(),
    const _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: '进度',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final childProvider = context.watch<ChildProfileProvider>();
    final trainingProvider = context.watch<TrainingProvider>();
    final child = childProvider.currentChild;
    final stats = trainingProvider.getStats();
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎头部
            FadeInDown(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      child?.name.substring(0, 1) ?? '宝',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '你好，${child?.name ?? '宝贝'}！',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '今天也要加油哦！💪',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 18),
                        SizedBox(width: 4.w),
                        Text(
                          '${trainingProvider.totalStars}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // 今日任务卡片
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _buildDailyTaskCard(context, trainingProvider),
            ),
            
            SizedBox(height: 24.h),
            
            // 训练模块入口
            const Text(
              '开始训练',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // 模块网格
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 16.w,
              childAspectRatio: 1.2,
              children: [
                _buildModuleCard(
                  context,
                  '📖',
                  '阅读训练',
                  '提升阅读能力',
                  AppTheme.primaryColor,
                  AppRoutes.mainTraining,
                  {'type': 'reading'},
                ),
                _buildModuleCard(
                  context,
                  '🧠',
                  '记忆训练',
                  '增强记忆力',
                  AppTheme.accentColor,
                  AppRoutes.mainTraining,
                  {'type': 'memory'},
                ),
                _buildModuleCard(
                  context,
                  '🎯',
                  '专注力',
                  '提高注意力',
                  AppTheme.warningColor,
                  AppRoutes.mainTraining,
                  {'type': 'focus'},
                ),
                _buildModuleCard(
                  context,
                  '🏃',
                  '感统游戏',
                  '感觉统合训练',
                  AppTheme.infoColor,
                  AppRoutes.mainTraining,
                  {'type': 'sensory'},
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // 最近成就
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '最近成就',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.achievement),
                        child: const Text('查看全部'),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildAchievementRow(trainingProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDailyTaskCard(BuildContext context, TrainingProvider provider) {
    final consecutiveDays = provider.consecutiveDays;
    final todayRecords = provider.todayRecords;
    final completedToday = todayRecords.length;
    final dailyGoal = 3;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.white, size: 28),
              SizedBox(width: 8.w),
              Text(
                '连续训练 $consecutiveDays 天！',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今日任务',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$completedToday / $dailyGoal 完成',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${(completedToday / dailyGoal * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: completedToday / dailyGoal,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModuleCard(
    BuildContext context,
    String icon,
    String title,
    String subtitle,
    Color color,
    String route,
    Map<String, dynamic>? arguments,
  ) {
    return FadeInUp(
      child: GestureDetector(
        onTap: () {
          if (arguments != null) {
            Navigator.pushNamed(context, route, arguments: arguments);
          } else {
            Navigator.pushNamed(context, route);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 50)),
              SizedBox(height: 12.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAchievementRow(TrainingProvider provider) {
    final stats = provider.getStats();
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('📚', '${stats.totalSessions}', '总训练'),
          _buildStatItem('⏱️', '${stats.totalMinutes}m', '总时长'),
          _buildStatItem('⭐', '${provider.totalStars}', '星星'),
          _buildStatItem('🔥', '${provider.consecutiveDays}天', '连续'),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        SizedBox(height: 4.h),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textHint,
          ),
        ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final childProvider = context.watch<ChildProfileProvider>();
    final child = childProvider.currentChild;
    
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // 个人信息卡片
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.accentColor],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: Colors.white,
                  child: Text(
                    child?.name.substring(0, 1) ?? '宝',
                    style: TextStyle(
                      fontSize: 40.sp,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  child?.name ?? '宝贝',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${child?.age}岁 · ${child?.grade}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // 设置选项
          _buildSettingItem(
            icon: Icons.person_outline,
            title: '儿童档案',
            subtitle: '管理儿童信息',
            onTap: () => Navigator.pushNamed(context, AppRoutes.childProfile),
          ),
          _buildSettingItem(
            icon: Icons.settings_outlined,
            title: '训练设置',
            subtitle: '调整训练参数',
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: '帮助中心',
            subtitle: '使用指南与 FAQ',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: '关于我们',
            subtitle: '版本信息',
            onTap: () {},
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
