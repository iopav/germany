import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/utils/root_wrapper.dart';
import 'core/utils/dev_screen.dart';
import 'features/home/presentation/home_screen.dart';

import 'core/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

import 'features/home/presentation/immersive_screen.dart';


void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
  
  await EasyLocalization.ensureInitialized();

  runApp(
   
    ProviderScope(
      child: EasyLocalization(
        
        supportedLocales: const [Locale('en', 'US')], //, Locale('zh', 'CN')
        path: 'assets/translations', 
        fallbackLocale: const Locale('en', 'US'), 
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale, 
      
      title: 'Mosaica',
      theme: AppTheme.lightTheme,
      initialRoute: '/', 
      routes: {
        '/': (context) => const RootWrapper(),       
        // '/register':(context) => const RegisterScreen(),
        // '/login':(context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/immersive': (context) => const ImmersiveScreen(),
        '/dev': (context) => const DevScreen(),
        // '/immersive': (context) => const ImmersiveScreen(),
        // '/settings': (context) => const SettingsScreen(), 
      },
    );
  }
}