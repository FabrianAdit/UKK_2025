import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart'; // Pastikan file ini ada

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://lyfeekizwyfwhdnfgvyn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5ZmVla2l6d3lmd2hkbmZndnluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg5NzQyNDUsImV4cCI6MjA1NDU1MDI0NX0.JFdTIvkZpC05nhWaFA9xDlpNkAiEbyNDJAU3697oE2A',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Login(), // Buka halaman login pertama kali
    );
  }
}
