import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plant_care/content/page/login.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadEnvIfPresent();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

Future<void> _loadEnvIfPresent() async {
  const fileName = '.env';
  try {
    if (await File(fileName).exists()) {
      await dotenv.load(fileName: fileName);
    }
  } catch (e) {
    // Swallow missing file errors to avoid crashes in dev.
    debugPrint('dotenv load skipped: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage());
  }
}
