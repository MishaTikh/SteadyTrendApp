import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'screens/dashboard.dart';
import 'screens/history.dart';
import 'package:provider/provider.dart';
import 'providers/weight_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/log.dart';
import 'screens/settings.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  try {
    await notificationService.init();
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing NotificationService: $e');
    }
  }

  int initialIndex = 0;
  try {
    final details = await notificationService.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      if (details.notificationResponse?.payload == 'log_weight') {
        initialIndex = 2;
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error getting notification launch details: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeightProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MyApp(initialIndex: initialIndex),
    ),
  );
}

class AppColors {
  static const Color primaryGreen = Color(0xFF0D5D1C);
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF1E2022);
  static const Color textLight = Color(0xFF6B7280);
  static const Color dividerColor = Color(0xFFE5E7EB);
  static const Color positiveGreen = Color(0xFF166534);
}

class MyApp extends StatelessWidget {
  final int initialIndex;

  const MyApp({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SteadyTrend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          background: AppColors.backgroundLight,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: AppColors.textDark),
          bodyMedium: TextStyle(color: AppColors.textLight),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.primaryGreen),
          titleTextStyle: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: AppColors.textLight,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: MainScreen(initialIndex: initialIndex),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const LogScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    NotificationService().onNotificationClick = (String? payload) {
      if (payload == 'log_weight') {
        setState(() {
          _currentIndex = 2; // Index of LogScreen
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          title: Row(
            children: [
              const Icon(
                Icons.trending_down,
                color: AppColors.primaryGreen,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'SteadyTrend',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: AppColors.textDark),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'DASHBOARD',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'HISTORY'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'LOG',
          ),
        ],
      ),
    );
  }
}
