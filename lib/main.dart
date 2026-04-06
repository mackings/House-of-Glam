import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Views/app_entry.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/constants/navcontroller.dart';
import 'package:hog/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadCurrency();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'House of Glam',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const AppEntryGate(),
      navigatorKey: NavigationController.navigatorKey,
    );
  }
}
