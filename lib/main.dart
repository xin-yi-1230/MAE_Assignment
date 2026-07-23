import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const APEventApp());
}

class APEventApp extends StatelessWidget {
  const APEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APEvent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        inputDecorationTheme: const InputDecorationTheme(filled: true),
      ),
      home: const AuthGate(),
    );
  }
}




/*Huberts Student home page
  class EventMateApp extends StatelessWidget {
  const EventMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => EventViewModel()),
        ChangeNotifierProvider(create: (_) => EventDetailViewModel()),
        ChangeNotifierProvider(create: (_) => BoothViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => ReviewViewModel()),
        ChangeNotifierProvider(create: (_) => NoticeViewModel()),
        ChangeNotifierProvider(create: (_) => NoticeViewModel()),
      ],
      child: MaterialApp(
        title: 'EventMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const MainScreen(),
      ),
    );
  }
}
*/