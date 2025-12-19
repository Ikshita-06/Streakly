import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_page.dart';
import 'dashboard_page.dart';
import 'theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wcsqmuuptmfxgrubewrt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indjc3FtdXVwdG1meGdydWJld3J0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3NzYwNDYsImV4cCI6MjA3ODM1MjA0Nn0.EARyv8_sz5FAOX53qXfFqAmeENEWhMmoLxtmxqUHtmY',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final themeModel = context.watch<ThemeModel>();

    return MaterialApp(
      title: 'Streakly',
      debugShowCheckedModeBanner: false,

      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ),

      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      themeMode: themeModel.currentTheme,

      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.session != null) {
            return DashboardPage(session: snapshot.data!.session!);
          }
          return const AuthPage();
        },
      ),
    );
  }
}