import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/client_provider.dart';
import 'providers/activation_provider.dart'; // Import the new provider
import 'screens/client_list_screen.dart';
import 'helpers/notification_helper.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await NotificationHelper.init(); // Temporarily disabled for debugging
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ClientProvider()),
        ChangeNotifierProvider(create: (context) => ActivationProvider()), // Add the activation provider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // _rescheduleNotifications(); // Temporarily disabled for debugging
  }

  Future<void> _rescheduleNotifications() async {
    await Future.delayed(const Duration(milliseconds: 100));
    developer.log('Rescheduling all notifications...', name: 'my_app.main');
    if (mounted) {
      final clientProvider = Provider.of<ClientProvider>(context, listen: false);
      await clientProvider.rescheduleAllNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Clientes IPTV',
      theme: darkTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
      home: const ClientListScreen(),
    );
  }
}
