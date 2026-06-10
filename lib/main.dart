import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

import 'core/navigation/app_router.dart';


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
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale, 
      
      title: 'Mosaica',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}