import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'registration_page.dart';
import '../Home/dashboard_page.dart';
import 'otp_verification_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameOrEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String usernameOrEmail = _usernameOrEmailController.text;
    final String password = _passwordController.text;

    final response = await http.post(
      Uri.parse('http://192.168.0.105:3000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final String token = responseBody['token'];
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final String username = decodedToken['username'];

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DashboardPage(username: username, email: usernameOrEmail),
        ),
      );
    } else if (response.statusCode == 403) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(
              email: responseBody['username'], verificationType: 'verify-otp'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to login: ${responseBody['message']}')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String labelText,
      bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color.fromRGBO(0, 0, 0, 0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
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
      obscureText: obscureText,
    );
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
                    'Masuk',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _usernameOrEmailController,
                  labelText: 'Username or Email',
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text('Forgot Password?',
                        style: TextStyle(color: Color(0xFF000015))),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000015),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Don\'t have an account?',
                        style: TextStyle(fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('Register',
                          style: TextStyle(color: Color(0xFF000015))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
