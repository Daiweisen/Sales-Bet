import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sales_bets/core/services/betting_service.dart';
import 'package:sales_bets/core/services/data_seeder.dart';
import 'package:sales_bets/core/services/event_service.dart';
import 'package:sales_bets/core/services/team_service.dart';
import 'package:sales_bets/firebase_options.dart';
import 'package:sales_bets/providers/betting_provider.dart';
import 'package:sales_bets/providers/event_provider.dart';
import 'package:sales_bets/providers/leaderboard_provider.dart';
import 'package:sales_bets/providers/team_provider.dart';
import 'package:sales_bets/providers/user_provider.dart';
import 'package:sales_bets/views/Onboarding/Onboarding_Screen.dart';
import 'package:sales_bets/views/home/home_screen.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/auth_services.dart';
import 'core/services/firestore_service.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'core/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authService = AuthService();
  final firestoreService = FirestoreService();
  final eventService = EventService();
  final teamService = TeamService();
  final dataSeeder = DataSeeder();
  
final prefs = await SharedPreferences.getInstance();
  final isSeeded = prefs.getBool('isSeeded') ?? false;

  if (!isSeeded) {
    print('Seeding database...');
    await dataSeeder.seedDatabase();
    await prefs.setBool('isSeeded', true);
    print('Database seeded successfully!');
  }
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const SalesBetsApp());
}

class SalesBetsApp extends StatelessWidget {
  const SalesBetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => EventsProvider(EventService())),
        ChangeNotifierProvider(create: (_) => TeamsProvider(TeamService())),
        
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (context) => BettingProvider(
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => EventService()),
        Provider(create: (_) => TeamService()),
        Provider(create: (_) => BettingService()),
        Provider(create: (_) => AuthService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Sales Bets',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
            routes: {
              '/onboarding': (context) => const OnboardingScreen(),
              '/home': (context) => const HomeScreen(),
            },
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const LoadingScreen();
        }

        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        // If user is not authenticated, show onboarding screen
        return const OnboardingScreen();
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.trending_up,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            
            // App Title
            Text(
              'Sales Bets',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Loading indicator
            const CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            
            // Loading text
            Text(
              'Loading...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}