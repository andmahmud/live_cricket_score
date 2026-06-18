import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/favorites_provider.dart';
import 'providers/match_provider.dart';
import 'providers/theme_provider.dart';
import 'services/api/cricket_api_service.dart';
import 'services/cache/local_cache_service.dart';
import 'services/logging/logger_service.dart';
import 'services/sync/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.init();
  AppLogger.logInfo('Starting Live Cricket Score app');

  final cacheService = LocalCacheService();
  await cacheService.init();

  final apiService = CricketApiService();
  final matchProvider = MatchProvider(
    apiService: apiService,
    cacheService: cacheService,
  );

  final syncService = SyncService(
    apiService: apiService,
    cacheService: cacheService,
    matchProvider: matchProvider,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => matchProvider),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        Provider.value(value: syncService),
        Provider.value(value: cacheService),
      ],
      child: const CricketAppLifecycleWrapper(),
    ),
  );
}

class CricketAppLifecycleWrapper extends StatefulWidget {
  const CricketAppLifecycleWrapper({super.key});

  @override
  State<CricketAppLifecycleWrapper> createState() =>
      _CricketAppLifecycleWrapperState();
}

class _CricketAppLifecycleWrapperState
    extends State<CricketAppLifecycleWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SyncService>().startAutoRefresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const CricketApp();
  }
}
