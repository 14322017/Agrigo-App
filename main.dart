import 'package:flutter/material.dart';
import 'splashscreen.dart'; // make sure this file exists in lib/
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // removes the debug banner
      title: 'AgriGo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 28, 185, 67),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // 👈 Start at SplashScreen instead of counter
    );
  }
}
