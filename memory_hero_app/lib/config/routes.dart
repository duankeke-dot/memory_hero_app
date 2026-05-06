import 'package:flutter/material.dart';

import '../screens/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/main_training_screen.dart';
import '../screens/reading/sand_writing_screen.dart';
import '../screens/reading/character_puzzle_screen.dart';
import '../screens/reading/colorful_reading_screen.dart';
import '../screens/reading/reading_challenge_screen.dart';
import '../screens/memory/number_sequence_screen.dart';
import '../screens/memory/memory_flip_screen.dart';
import '../screens/memory/n_back_screen.dart';
import '../screens/memory/story_recall_screen.dart';
import '../screens/focus/schulte_grid_screen.dart';
import '../screens/focus/ball_tracking_screen.dart';
import '../screens/focus/find_difference_screen.dart';
import '../screens/sensory/balance_challenge_screen.dart';
import '../screens/parent/parent_dashboard_screen.dart';
import '../screens/parent/progress_report_screen.dart';
import '../screens/parent/settings_screen.dart';
import '../screens/profile/child_profile_screen.dart';
import '../screens/achievement/achievement_screen.dart';
import '../screens/placeholder_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String mainTraining = '/main-training';
  static const String parentDashboard = '/parent-dashboard';
  static const String progressReport = '/progress-report';
  static const String settings = '/settings';
  static const String childProfile = '/child-profile';
  static const String achievement = '/achievement';
  
  // 阅读训练
  static const String sandWriting = '/sand-writing';
  static const String characterPuzzle = '/character-puzzle';
  static const String colorfulReading = '/colorful-reading';
  static const String readingChallenge = '/reading-challenge';
  
  // 记忆训练
  static const String numberSequence = '/number-sequence';
  static const String memoryFlip = '/memory-flip';
  static const String nBack = '/n-back';
  static const String storyRecall = '/story-recall';
  
  // 专注力训练
  static const String schulteGrid = '/schulte-grid';
  static const String ballTracking = '/ball-tracking';
  static const String findDifference = '/find-difference';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case mainTraining:
        return MaterialPageRoute(builder: (_) => const MainTrainingScreen());
      case parentDashboard:
        return MaterialPageRoute(builder: (_) => const ParentDashboardScreen());
      case progressReport:
        return MaterialPageRoute(
          builder: (_) => const ProgressReportScreen(),
          settings: settings,
        );
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case childProfile:
        return MaterialPageRoute(builder: (_) => const ChildProfileScreen());
      case achievement:
        return MaterialPageRoute(builder: (_) => const AchievementScreen());
      
      // 阅读训练
      case sandWriting:
        return MaterialPageRoute(builder: (_) => const SandWritingScreen());
      case characterPuzzle:
        return MaterialPageRoute(builder: (_) => const CharacterPuzzleScreen());
      case colorfulReading:
        return MaterialPageRoute(builder: (_) => const ColorfulReadingScreen());
      case readingChallenge:
        return MaterialPageRoute(builder: (_) => const ReadingChallengeScreen());
      
      // 记忆训练
      case numberSequence:
        return MaterialPageRoute(builder: (_) => const NumberSequenceScreen());
      case memoryFlip:
        return MaterialPageRoute(builder: (_) => const MemoryFlipScreen());
      case nBack:
        return MaterialPageRoute(builder: (_) => const NBackScreen());
      case storyRecall:
        return MaterialPageRoute(builder: (_) => const StoryRecallScreen());
      
      // 专注力训练
      case schulteGrid:
        return MaterialPageRoute(builder: (_) => const SchulteGridScreen());
      case ballTracking:
        return MaterialPageRoute(builder: (_) => const BallTrackingScreen());
      case findDifference:
        return MaterialPageRoute(builder: (_) => const FindDifferenceScreen());
      
      // 感统训练
      case 'balance_challenge':
        return MaterialPageRoute(builder: (_) => const BalanceChallengeScreen());
      case 'rhythm_master':
      case 'touch_guess':
      case 'eye_exercise':
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(
            title: '功能开发中',
            message: '该感统游戏正在开发中，敬请期待！',
          ),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
