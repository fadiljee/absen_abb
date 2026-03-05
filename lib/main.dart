import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Sesuaikan lokasi import-nya

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telkom Absen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto', // Atau font yang kamu gunakan
      ),
      // UBAH BAGIAN INI:
      home: const SplashScreen(),
    );
  }
}