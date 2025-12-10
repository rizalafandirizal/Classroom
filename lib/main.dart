import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';

const supabaseUrl = 'https://aoqrehskizzhqztbwybb.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvcXJlaHNraXp6aHF6dGJ3eWJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzMTAwMDUsImV4cCI6MjA4MDg4NjAwNX0.TMXZYSSjuD5kDY4wPMYim-b_33zPgaaqvN84uAtpzn8';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Classroom',
      home: const SplashScreen(),
    );
  }
}
