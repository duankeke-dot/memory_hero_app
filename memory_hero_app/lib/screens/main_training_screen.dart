import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/training_record.dart';
import '../config/routes.dart';

/// 主训练选择页面
class MainTrainingScreen extends StatelessWidget {
  const MainTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final trainingType = args?['type'] as String?;
    
    final modules = TrainingModule.getByType(TrainingType.fromValue(trainingType ?? 'reading'));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(TrainingType.fromValue(trainingType ?? 'reading').displayName),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return _buildModuleCard(context, module);
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildModuleCard(BuildContext context, TrainingModule module) {
    return GestureDetector(
      onTap: () => _navigateToGame(context, module.id),
      child: Container(
        decoration: BoxDecoration(
          color: module.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: module.color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(module.icon, style: const TextStyle(fontSize: 50)),
            SizedBox(height: 12.h),
            Text(
              module.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: module.color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                module.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToGame(BuildContext context, String moduleId) {
    String? route;
    
    switch (moduleId) {
      // 阅读训练
      case 'sand_writing':
        route = AppRoutes.sandWriting;
        break;
      case 'character_puzzle':
        route = AppRoutes.characterPuzzle;
        break;
      case 'colorful_reading':
        route = AppRoutes.colorfulReading;
        break;
      case 'reading_challenge':
        route = AppRoutes.readingChallenge;
        break;
      
      // 记忆训练
      case 'number_sequence':
        route = AppRoutes.numberSequence;
        break;
      case 'memory_flip':
        route = AppRoutes.memoryFlip;
        break;
      case 'n_back':
        route = AppRoutes.nBack;
        break;
      case 'story_recall':
        route = AppRoutes.storyRecall;
        break;
      
      // 专注力训练
      case 'schulte_grid':
        route = AppRoutes.schulteGrid;
        break;
      case 'ball_tracking':
        route = AppRoutes.ballTracking;
        break;
      case 'find_difference':
        route = AppRoutes.findDifference;
        break;
      
      // 感统训练
      case 'balance_challenge':
        route = 'balance_challenge';
        break;
      case 'rhythm_master':
        route = 'rhythm_master';
        break;
      case 'touch_guess':
        route = 'touch_guess';
        break;
      case 'eye_exercise':
        route = 'eye_exercise';
        break;
      
      default:
        // 未实现的游戏
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('该游戏正在开发中！')),
        );
        return;
    }
    
    if (route != null) {
      Navigator.pushNamed(context, route);
    }
  }
}
