import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/theme_provider.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/live_matches_screen.dart';
import 'screens/match_details_screen.dart';
import 'screens/recent_results_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/upcoming_matches_screen.dart';

class CricketApp extends StatelessWidget {
  const CricketApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Live Cricket Score',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: Routes.home,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case Routes.liveMatches:
        return MaterialPageRoute(
          builder: (_) => const LiveMatchesScreen(),
          settings: settings,
        );
      case Routes.upcomingMatches:
        return MaterialPageRoute(
          builder: (_) => const UpcomingMatchesScreen(),
          settings: settings,
        );
      case Routes.recentResults:
        return MaterialPageRoute(
          builder: (_) => const RecentResultsScreen(),
          settings: settings,
        );
      case Routes.matchDetails:
        return MaterialPageRoute(
          builder: (_) => const MatchDetailsScreen(),
          settings: settings,
        );
      case Routes.favorites:
        return MaterialPageRoute(
          builder: (_) => const FavoritesScreen(),
          settings: settings,
        );
      case Routes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
    }
  }
}
