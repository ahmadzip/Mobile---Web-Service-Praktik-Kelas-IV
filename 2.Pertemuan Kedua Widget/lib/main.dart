import 'package:flutter/material.dart';
import 'package:helloworld/widgets/herosection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.network(
              'https://ammomed.com/_next/image?url=%2Flogo.png&w=256&q=75',
              height: 40,
            ),
            ElevatedButton(
              onPressed: () {
                print('Login button pressed');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 253, 255, 255),
                backgroundColor: const Color.fromARGB(255, 12, 117, 100),
              ),
              child: const Text('Sign Up'),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: const HeroSection(),
    );
  }
}
