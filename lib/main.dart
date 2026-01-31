import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'services/ritual_service.dart';
import 'services/settings_service.dart';
import 'screens/login_screen.dart';
import 'screens/ritual_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize flutter_animate properly for web
  Animate.restartOnHotReload = true;
  
  // Skip system UI overlay on web
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.surfaceDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
  
  // Initialize Supabase
  final supabaseService = SupabaseService();
  await supabaseService.initialize();
  
  // Initialize SettingsService
  final settingsService = SettingsService();
  await settingsService.loadSettings();
  
  runApp(AnimeConnesseApp(
    supabaseService: supabaseService,
    settingsService: settingsService,
  ));
}

class AnimeConnesseApp extends StatelessWidget {
  final SupabaseService supabaseService;
  final SettingsService settingsService;

  const AnimeConnesseApp({
    super.key,
    required this.supabaseService,
    required this.settingsService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: supabaseService),
        ChangeNotifierProvider(
          create: (_) => AuthService(supabaseService),
        ),
        ChangeNotifierProvider(
          create: (_) => RitualService(supabaseService),
        ),
        ChangeNotifierProvider.value(value: settingsService),
      ],
      child: MaterialApp(
        title: 'Anime Connesse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.isAuthenticated) {
          return const RitualDashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}