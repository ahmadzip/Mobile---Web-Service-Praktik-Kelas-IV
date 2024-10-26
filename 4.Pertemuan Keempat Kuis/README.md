Nama: Ahmad Suleman  
Npm: 5220411084

# TUGAS QUIZ MEMBUAT APLIKASI RESTORAN

Modifikasi main.dart

```dart
import 'package:flutter/material.dart'; // Mengimpor paket material design Flutter
import 'login_page.dart'; // Mengimpor file login_page.dart
import 'dashboard_page.dart'; // Mengimpor file dashboard_page.dart

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
        '/dashboard': (context) => const DashboardPage(username: ''), // Rute untuk halaman dashboard dengan parameter username kosong
      },
    );
  }
}
```

setelah itu saya membuat sebuah api dimana api nya bisa registrasi dan login menggunakan node.js dan express.js dengan database sqlite di sini saya tidak akan menjelaskan code dari api tersebut, jadi lanjut ke file login_page.dart

login_page.dart di sini saya membuat halaman login dengan input username atau email dan password yang akan dikirim ke API untuk login pengguna dan mendapatkan token JWT yang akan digunakan untuk otentikasi pengguna

```dart
import 'package:flutter/material.dart'; // Mengimpor paket material design Flutter
import 'package:http/http.dart' as http; // Mengimpor paket http untuk melakukan permintaan HTTP
import 'dart:convert'; // Mengimpor paket dart:convert untuk mengonversi data JSON
import 'package:jwt_decoder/jwt_decoder.dart'; // Mengimpor paket jwt_decoder untuk mendekode token JWT
import 'registration_page.dart'; // Mengimpor file registration_page.dart
import 'dashboard_page.dart'; // Mengimpor file dashboard_page.dart

class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); // Konstruktor LoginPage dengan kunci super

  @override
  _LoginPageState createState() => _LoginPageState(); // Membuat state untuk LoginPage
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameOrEmailController =
      TextEditingController(); // Kontroler untuk input username atau email
  final TextEditingController _passwordController = TextEditingController(); // Kontroler untuk input password

  Future<void> _login() async {
    final String usernameOrEmail = _usernameOrEmailController.text; // Mendapatkan teks dari kontroler username atau email
    final String password = _passwordController.text; // Mendapatkan teks dari kontroler password

    final response = await http.post(
      Uri.parse('http://192.168.0.105:3000/login'), // Mengirim permintaan POST ke URL login
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', // Menetapkan header konten tipe
      },
      body: jsonEncode(<String, String>{
        'usernameOrEmail': usernameOrEmail, // Menyertakan username atau email dalam body permintaan
        'password': password, // Menyertakan password dalam body permintaan
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body); // Mendekode respons JSON
      final String token = responseData['token']; // Mendapatkan token dari respons
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token); // Mendekode token JWT
      final String username = decodedToken['username']; // Mendapatkan username dari token yang didekode

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login berhasil!')), // Menampilkan snackbar jika login berhasil
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(username: username), // Navigasi ke halaman dashboard dengan username
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal login: ${response.body}')), // Menampilkan snackbar jika login gagal
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Menetapkan warna latar belakang putih
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Menambahkan padding horizontal
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Menyelaraskan kolom ke tengah
              children: <Widget>[
                Image.asset(
                  'images/logo.jpg', // Menampilkan gambar logo
                  width: 200,
                ),
                const SizedBox(height: 30), // Menambahkan jarak vertikal
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Masuk', // Teks judul halaman login
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20), // Menambahkan jarak vertikal
                TextField(
                  controller: _usernameOrEmailController, // Menghubungkan kontroler ke input username atau email
                  decoration: InputDecoration(
                    labelText: 'Username atau Email', // Label untuk input username atau email
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10), // Padding konten input
                  ),
                ),
                const SizedBox(height: 10), // Menambahkan jarak vertikal
                TextField(
                  controller: _passwordController, // Menghubungkan kontroler ke input password
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi', // Label untuk input password
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10), // Padding konten input
                  ),
                  obscureText: true, // Menyembunyikan teks input password
                ),
                const SizedBox(height: 10), // Menambahkan jarak vertikal
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Lupa Kata Sandi?',
                        style: TextStyle(color: Colors.blue)), // Teks tombol lupa kata sandi
                  ),
                ),
                const SizedBox(height: 20), // Menambahkan jarak vertikal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15), // Padding tombol
                      backgroundColor: Colors.blue, // Warna latar belakang tombol
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)), // Bentuk tombol
                    ),
                    onPressed: _login, // Memanggil fungsi login saat tombol ditekan
                    child: const Text('Masuk', style: TextStyle(fontSize: 18)), // Teks tombol login
                  ),
                ),
                const SizedBox(height: 20), // Menambahkan jarak vertikal
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Belum punya akun?',
                        style: TextStyle(fontSize: 16)), // Teks pertanyaan belum punya akun
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(), // Navigasi ke halaman registrasi
                          ),
                        );
                      },
                      child: const Text('Daftar',
                          style: TextStyle(color: Colors.blue)), // Teks tombol daftar
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
```

Di sini saya mengalami kendala tentang gimana caranya decode token jwt di flutter, awalnya saya menggunakan package [dart_jsonwebtoken](https://pub.dev/packages/dart_jsonwebtoken) tapi terdapat error

![alt text](<Flutter/images/readme/Screenshot 2024-10-15 210729.png>)

setelah saya cari cari nemu [situs ini](https://medium.com/@hpatilabhi10/understanding-jwt-tokens-in-flutter-0dfd0f495715) yang memberikan solusi yaitu menggunakan package [jwt_decoder](https://pub.dev/packages/jwt_decoder) dan berhasil

selanjutnya registrasi_page.dart di sini saya membuat halaman registrasi dengan input username, email, dan password yang akan dikirim ke API untuk registrasi pengguna baru dan di simpan di database sqlite

```dart
import 'package:flutter/material.dart'; // Mengimpor paket material design Flutter
import 'package:http/http.dart' as http; // Mengimpor paket http untuk melakukan permintaan HTTP
import 'dart:convert'; // Mengimpor paket dart:convert untuk mengonversi data JSON

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key}); // Konstruktor RegisterPage dengan kunci super

  @override
  _RegisterPageState createState() => _RegisterPageState(); // Membuat state untuk RegisterPage
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController(); // Kontroler untuk input username
  final TextEditingController _emailController = TextEditingController(); // Kontroler untuk input email
  final TextEditingController _passwordController = TextEditingController(); // Kontroler untuk input password

  Future<void> _register() async {
    final String username = _usernameController.text; // Mendapatkan teks dari kontroler username
    final String email = _emailController.text; // Mendapatkan teks dari kontroler email
    final String password = _passwordController.text; // Mendapatkan teks dari kontroler password

    final response = await http.post(
      Uri.parse('http://192.168.0.105:3000/register'), // Mengirim permintaan POST ke URL register
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', // Menetapkan header konten tipe
      },
      body: jsonEncode(<String, String>{
        'username': username, // Menyertakan username dalam body permintaan
        'email': email, // Menyertakan email dalam body permintaan
        'password': password, // Menyertakan password dalam body permintaan
      }),
    );

    if (response.statusCode == 201) {
      // Registrasi berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil!')), // Menampilkan snackbar jika registrasi berhasil
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } else {
      // Registrasi gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal registrasi: ${response.body}')), // Menampilkan snackbar jika registrasi gagal
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Menetapkan warna latar belakang putih
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Menambahkan padding horizontal
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Menyelaraskan kolom ke tengah
              children: <Widget>[
                Image.asset(
                  'images/logo.jpg', // Menampilkan gambar logo
                  width: 200,
                ),
                const SizedBox(height: 30), // Menambahkan jarak vertikal
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Daftar', // Teks judul halaman registrasi
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20), // Menambahkan jarak vertikal
                TextField(
                  controller: _usernameController, // Menghubungkan kontroler ke input username
                  decoration: InputDecoration(
                    labelText: 'Username', // Label untuk input username
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10), // Padding konten input
                  ),
                ),
                const SizedBox(height: 10), // Menambahkan jarak vertikal
                TextField(
                  controller: _emailController, // Menghubungkan kontroler ke input email
                  decoration: InputDecoration(
                    labelText: 'Email', // Label untuk input email
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10), // Padding konten input
                  ),
                ),
                const SizedBox(height: 10), // Menambahkan jarak vertikal
                TextField(
                  controller: _passwordController, // Menghubungkan kontroler ke input password
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi', // Label untuk input password
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10), // Padding konten input
                  ),
                  obscureText: true, // Menyembunyikan teks input password
                ),
                const SizedBox(height: 20), // Menambahkan jarak vertikal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15), // Padding tombol
                      backgroundColor: Colors.blue, // Warna latar belakang tombol
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)), // Bentuk tombol
                    ),
                    onPressed: _register, // Memanggil fungsi registrasi saat tombol ditekan
                    child:
                        const Text('Daftar', style: TextStyle(fontSize: 18)), // Teks tombol registrasi
                  ),
                ),
                const SizedBox(height: 20), // Menambahkan jarak vertikal
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Sudah punya akun?',
                        style: TextStyle(fontSize: 16)), // Teks pertanyaan sudah punya akun
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Kembali ke halaman login
                      },
                      child: const Text('Masuk',
                          style: TextStyle(color: Colors.blue)), // Teks tombol masuk
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
```

dan yang terakhir dashboard_page.dart di sini saya membuat halaman dashboard dengan menampilkan username pengguna yang berhasil login

```dart
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final String username;

  const DashboardPage({super.key, required this.username});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Product> products = [
    Product(
      name: 'Produk 1',
      description: 'Ini adalah produk pertama',
      imageUrl: 'https://picsum.photos/id/1074/400/400',
    ),
    Product(
      name: 'Produk 2',
      description: 'Ini adalah produk kedua',
      imageUrl: 'https://picsum.photos/id/1084/400/400',
    ),
    Product(
      name: 'Produk 3',
      description: 'Ini adalah produk ketiga',
      imageUrl: 'https://picsum.photos/id/1084/400/400',
    ),
    Product(
      name: 'Produk 4',
      description: 'Ini adalah produk keempat',
      imageUrl: 'https://picsum.photos/id/1084/400/400',
    ),
    Product(
      name: 'Produk 5',
      description: 'Ini adalah produk kelima',
      imageUrl: 'https://picsum.photos/id/1084/400/400',
    ),
  ];

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dasbor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      backgroundColor: Colors.white, // Set background color to white
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      NetworkImage('https://picsum.photos/id/1005/400/400'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.username,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Selamat Pagi',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Image.network(
              'https://picsum.photos/id/1011/800/200',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              product.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  product.description,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: () {
                              // Handle product click
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final String description;
  final String imageUrl;

  Product({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

```

![alt text](<Flutter/images/readme/Screenshot 2024-10-15 215022.png>)
![alt text](<Flutter/images/readme/Screenshot 2024-10-15 215058.png>)
![alt text](<Flutter/images/readme/Screenshot 2024-10-15 215141.png>)



https://github.com/user-attachments/assets/f3cdde14-af9d-4dba-91a4-517513a16ba2


1. [Learn Flutter: How to Add Images in Your Flutter App](https://medium.com/@blup-tool/learn-flutter-how-to-add-images-in-your-flutter-app-359c27600064)  
   Penjelasan tentang cara menambahkan gambar ke aplikasi Flutter.
2. [Build Flutter ListView Food App Navigator ListView Tutorial](https://bigknol.com/flutter/build-flutter-listview-food-app-navigator-listview-tutorial/)  
   Tutorial untuk membuat aplikasi makanan menggunakan ListView dan navigasi di Flutter.
3. [Understanding JWT Tokens in Flutter](https://medium.com/@hpatilabhi10/understanding-jwt-tokens-in-flutter-0dfd0f495715)  
   Penjelasan mengenai JWT (JSON Web Tokens) di Flutter.
4. [Describe Named Routes and How They Are Used for Navigation in Flutter](https://medium.com/@chetan.akarte/describe-named-routes-and-how-they-are-used-for-navigation-in-flutter-7b2a9716bab9)  
   Pembahasan tentang Named Routes dan penggunaannya untuk navigasi di Flutter.
5. [How to Import Data from One Page to Another in Flutter](https://www.geeksforgeeks.org/how-to-import-data-from-one-page-to-another-in-flutter/)  
   Tutorial mengenai cara mengimpor data dari satu halaman ke halaman lain di Flutter.

