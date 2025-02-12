import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://lyfeekizwyfwhdnfgvyn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5ZmVla2l6d3lmd2hkbmZndnluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg5NzQyNDUsImV4cCI6MjA1NDU1MDI0NX0.JFdTIvkZpC05nhWaFA9xDlpNkAiEbyNDJAU3697oE2A',
  );
  runApp(const MyApp());
}
        
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 255, 242)),
        useMaterial3: true,
      ),
      home: const Login(),
    );
  }
}

