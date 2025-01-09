import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String verificationType; // Add verificationType parameter

  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.verificationType, // Initialize verificationType
  });

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(); // Add password controller for reset-password

  Future<void> _verifyOtp() async {
    final String otp = _otpController.text;
    final String url = widget.verificationType == 'reset-password'
        ? 'http://192.168.0.105:3000/reset-password'
        : 'http://192.168.0.105:3000/verify-otp';

    final Map<String, String> body = {
      'email': widget.email,
      'otp': otp,
    };

    if (widget.verificationType == 'reset-password') {
      body['password'] =
          _passwordController.text; // Add password to body if reset-password
    }

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to verify OTP: ${responseBody['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Enter OTP',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _otpController,
                  decoration: InputDecoration(
                    labelText: 'OTP',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(0, 0, 0, 0.15),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(0, 0, 0, 0.15),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 15,
                    ),
                  ),
                ),
                if (widget.verificationType == 'reset-password') ...[
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Enter New Password',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                    ),
                    obscureText: true,
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: const Color(0xFF000015),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _verifyOtp,
                    child: const Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
