import 'package:flutter/material.dart'; // Mengimpor paket material design Flutter
import 'Auth/login_page.dart'; // Mengimpor file login_page.dart
import 'Home/dashboard_page.dart'; // Mengimpor file dashboard_page.dart

void main() {
  runApp(const MyApp()); // Menjalankan aplikasi Flutter dengan widget MyApp
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Konstruktor MyApp dengan kunci super

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo', // Judul aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema aplikasi dengan warna utama biru
      ),
      initialRoute: '/login', // Rute awal aplikasi adalah halaman login
      routes: {
        '/login': (context) => const LoginPage(), // Rute untuk halaman login
        '/dashboard': (context) => const DashboardPage(
              username: '',
              email: '',
            ), // Rute untuk halaman dashboard dengan parameter username kosong
      },
    );
  }
}
