import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/api_config.dart';
import 'config/theme.dart';
import 'providers/expense_provider.dart';
import 'providers/room_provider.dart';
import 'screens/landing_screen.dart';
import 'screens/room_screen.dart';
import 'screens/server_setup_screen.dart';
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  final config = await ApiConfig.load();
  runApp(TabbrApp(config: config));
}

class TabbrApp extends StatelessWidget {
  final ApiConfig config;

  const TabbrApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiConfig>.value(value: config),
        ProxyProvider<ApiConfig, ApiService>(
          update: (_, apiConfig, _) => ApiService(apiConfig),
        ),
        ChangeNotifierProxyProvider2<ApiService, ApiConfig, RoomProvider>(
          create: (ctx) => RoomProvider(
            api: ctx.read<ApiService>(),
            config: ctx.read<ApiConfig>(),
          ),
          update: (_, api, cfg, previous) =>
              previous ?? RoomProvider(api: api, config: cfg),
        ),
        ChangeNotifierProxyProvider<ApiService, ExpenseProvider>(
          create: (ctx) =>
              ExpenseProvider(api: ctx.read<ApiService>()),
          update: (_, api, previous) =>
              previous ?? ExpenseProvider(api: api),
        ),
      ],
      child: MaterialApp(
        title: 'Tabbr',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ApiConfig>();
    if (!config.hasServerUrl) {
      return const ServerSetupScreen();
    }
    final hasRoom = context.watch<RoomProvider>().room != null;
    if (hasRoom) {
      return const RoomScreen();
    }
    return const LandingScreen();
  }
}