import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dishaan_invoice_xpert/screens/auth/login_screen.dart';
import 'package:dishaan_invoice_xpert/screens/home/home_screen.dart';
import 'package:dishaan_invoice_xpert/providers/auth_provider.dart';
import 'package:dishaan_invoice_xpert/providers/settings_provider.dart';

class BillingApp extends StatefulWidget {
  const BillingApp({Key? key}) : super(key: key);

  @override
  State<BillingApp> createState() => _BillingAppState();
}

class _BillingAppState extends State<BillingApp> {
  @override
  void initState() {
    super.initState();

    // Initialize settings
    Future.delayed(Duration.zero, () {
      Provider.of<SettingsProvider>(context, listen: false).loadSettings();
      Provider.of<AuthProvider>(context, listen: false).checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: settingsProvider.businessName ?? 'Billing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: authProvider.isInitialized
          ? (authProvider.isLoggedIn || !settingsProvider.enableLogin
          ? const HomeScreen()
          : const LoginScreen())
          : const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}