import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/theme.dart';
import 'config/colors.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ai_processing_screen.dart';
import 'screens/provider_recommendation_screen.dart';
import 'screens/agent_workflow_screen.dart';
import 'screens/booking_simulation_screen.dart';
import 'screens/followup_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(
    const ProviderScope(
      child: ServiceSathiApp(),
    ),
  );
}

class ServiceSathiApp extends StatefulWidget {
  const ServiceSathiApp({super.key});

  @override
  State<ServiceSathiApp> createState() => _ServiceSathiAppState();
}

class _ServiceSathiAppState extends State<ServiceSathiApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServiceSathi AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  String _currentScreen = 'splash'; // splash, onboarding, main
  int _navIndex = 0;
  String _lastSearchQuery = '';

  void _navigateTo(String screen, {String? query}) {
    setState(() {
      _currentScreen = screen;
      if (query != null) _lastSearchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentScreen) {
      case 'splash':
        return SplashScreen(
          onComplete: () => _navigateTo('onboarding'),
        );

      case 'onboarding':
        return OnboardingScreen(
          onComplete: () => _navigateTo('main'),
        );

      case 'processing':
        return AIProcessingScreen(
          userRequest: _lastSearchQuery,
          onComplete: () => _navigateTo('recommendations'),
        );

      case 'recommendations':
        return ProviderRecommendationScreen(
          onBook: () => _navigateTo('booking'),
          onBack: () => _navigateTo('main'),
        );

      case 'booking':
        return BookingSimulationScreen(
          onContinue: () => _navigateTo('followup'),
        );

      case 'followup':
        return FollowUpScreen(
          onDone: () => _navigateTo('main'),
        );

      case 'workflow':
        return const AgentWorkflowScreen();

      case 'main':
      default:
        return BottomNavShell(
          currentIndex: _navIndex,
          onTap: (index) {
            if (index == 2) {
              // Center AI button — trigger search
              _navigateTo('processing',
                  query: 'AC repair chahiye Gulberg mein, budget 2000');
              return;
            }
            setState(() => _navIndex = index);
          },
          child: IndexedStack(
            index: _navIndex > 2 ? _navIndex - 1 : _navIndex,
            children: [
              HomeScreen(
                onSearch: (query) =>
                    _navigateTo('processing', query: query),
                onViewWorkflow: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AgentWorkflowScreen(),
                    ),
                  );
                },
                onViewNotifications: () => setState(() => _navIndex = 3),
                onViewProfile: () => setState(() => _navIndex = 4),
                onCategoryTap: (type) => _navigateTo('processing',
                    query: '$type service needed near me'),
              ),
              const AgentWorkflowScreen(),
              const NotificationScreen(),
              const ProfileScreen(),
            ],
          ),
        );
    }
  }
}
