Nama: Ahmad Suleman  
Npm: 5220411084

# TUGAS HASIL PEMBELAJARAN MINGGU KE-5

Berikut Desain yang saya buat yang nantinya akan saya implementasikan ke dalam aplikasi web yang saya buat next week.

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://embed.figma.com/design/07FrSCrvK2ltyPKAECKWDx/Ammomed?node-id=0-1&embed-host=share" allowfullscreen></iframe>

[Link Figma](https://www.figma.com/design/07FrSCrvK2ltyPKAECKWDx/Ammomed?node-id=0-1&m=dev&t=tiOsWFBxsjXITrn7-1)

## Api

### 1. POST /register

Disini saya menggunakan endpoint register untuk mendaftarkan user baru. Berikut adalah code yang saya buat untuk endpoint register.

Parameter yang di butuhkan:

- username ( harus unik )
- email ( harus unik )
- password ( password yang akan di hash )
- otpMethod ( metode otp yang akan di gunakan )

```javascript
// Menangani permintaan POST ke endpoint /register
router.post("/register", async (req, res) => {
  // Mendestrukturisasi username, email, password, dan otpMethod dari body permintaan
  const { username, email, password, otpMethod } = req.body;
  try {
    // Mencari pengguna yang sudah ada berdasarkan username atau email
    const existingUser = await User.findOne({
      where: {
        [Sequelize.Op.or]: [{ username }, { email }],
      },
    });
    // Jika pengguna sudah ada, kirim respons status 400 dengan pesan kesalahan
    if (existingUser) {
      return res.status(400).json({ message: "User already exists!" });
    }

    // Meng-hash password menggunakan bcrypt dengan salt rounds 10
    const hashedPassword = await bcrypt.hash(password, 10);
    // Menghasilkan OTP (One-Time Password)
    const otp = generateOtp();
    // Membuat pengguna baru di database dengan username, email, password yang di-hash, dan OTP
    await User.create({ username, email, password: hashedPassword, otp });
    // Jika metode OTP adalah "Gmail", kirim email verifikasi
    if (otpMethod === "Gmail") {
      const subject = "OTP for email verification"; // Subjek email
      const html = `<p>Your OTP code is: <strong>${otp}</strong></p>`; // Konten HTML email
      // Mengirim email menggunakan fungsi sendMail dan menyimpan hasilnya
      const emailResult = await sendMail(email, subject, html);
      // Jika pengiriman email gagal, kirim respons status 500 dengan pesan kesalahan
      if (!emailResult.status) {
        return res.status(500).json({ message: "Failed to send OTP email." });
      }
    }

    // Jika semua berhasil, kirim respons status 201 dengan pesan sukses dan metode OTP
    return res
      .status(201)
      .json({ message: "User created successfully!", otpMethod });
  } catch (error) {
    // Menangkap kesalahan, mencetaknya ke konsol, dan mengirim respons status 500 dengan pesan kesalahan
    console.log(error);
    return res.status(500).json({ message: "Internal server error!" });
  }
});
```

### 2. POST /verify

Disini saya menggunakan endpoint verify untuk memverifikasi user yang sudah mendaftar. Berikut adalah code yang saya buat untuk endpoint verify.

Parameter yang di butuhkan:

- email
- otp

```javascript
// Menangani permintaan POST ke endpoint /verify-otp
router.post("/verify-otp", async (req, res) => {
  // Mendestrukturisasi username dan otp dari body permintaan
  const { username, otp } = req.body;

  try {
    // Mencari pengguna berdasarkan username dan otp
    const user = await User.findOne({ where: { username, otp } });

    // Jika pengguna tidak ditemukan, kirim respons status 400 dengan pesan kesalahan
    if (!user) {
      return res.status(400).json({ message: "Invalid OTP!" });
    }

    // Menandai pengguna sebagai terverifikasi
    user.isVerified = true;
    // Menghapus OTP dari pengguna
    user.otp = null;
    // Menyimpan perubahan ke database
    await user.save();

    // Jika semua berhasil, kirim respons status 200 dengan pesan sukses
    return res.status(200).json({ message: "User verified successfully!" });
  } catch (error) {
    // Menangkap kesalahan, mencetaknya ke konsol, dan mengirim respons status 500 dengan pesan kesalahan
    console.log(error);
    return res.status(500).json({ message: "Internal server error!" });
  }
});
```

## 3. POST /login

Disini saya menggunakan endpoint login untuk login user, dimana terdapat beberapa syarat login yang harus di penenuhi

Syarat:

- username ( harus ada di database )
- password ( harus sesuai dengan password yang ada di database )
- verifikasi otp ( harus sesuai dengan otp yang di kirim ke email user )

Parameter yang di butuhkan:

- usernameOrEmail ( username atau email )
- password ( password )

```javascript
// Menangani permintaan POST ke endpoint /login
router.post("/login", async (req, res) => {
  // Mendestrukturisasi usernameOrEmail dan password dari body permintaan
  const { usernameOrEmail, password } = req.body;

  try {
    // Mencari pengguna berdasarkan username atau email
    const user = await User.findOne({
      where: {
        [Sequelize.Op.or]: [
          { username: usernameOrEmail },
          { email: usernameOrEmail },
        ],
      },
    });

    // Jika pengguna tidak ditemukan, kirim respons status 401 dengan pesan kesalahan
    if (!user) {
      return res.status(401).json({ message: "Invalid credentials!" });
    }

    // Jika pengguna belum diverifikasi, kirim respons status 403 dengan pesan kesalahan
    if (!user.isVerified) {
      return res
        .status(403)
        .json({ message: "User not verified!", username: user.username });
    }

    // Membandingkan password yang diberikan dengan password yang di-hash di database
    if (await bcrypt.compare(password, user.password)) {
      // Jika password cocok, buat token JWT dengan username pengguna dan kunci rahasia
      const token = jwt.sign({ username: user.username }, SECRET_KEY, {
        expiresIn: "1h",
      });
      // Kirim respons status 200 dengan pesan sukses dan token
      return res.status(200).json({ message: "Login successful!", token });
    } else {
      // Jika password tidak cocok, kirim respons status 401 dengan pesan kesalahan
      return res.status(401).json({ message: "Invalid credentials!" });
    }
  } catch (error) {
    // Menangkap kesalahan, mencetaknya ke konsol, dan mengirim respons status 500 dengan pesan kesalahan
    return res.status(500).json({ message: "Internal server error!" });
  }
});
```

## Metode Untuk Mengirim Email

Disini saya menggunakan metode untuk mengirim email verifikasi ke user yang sudah mendaftar. Berikut adalah code yang saya buat untuk metode sendMail menggunakan nodemailer.

```javascript
// Mengimpor modul nodemailer untuk mengirim email
const nodemailer = require("nodemailer");

// Fungsi asinkron untuk mengirim email
const sendMail = async (to, subject, html) => {
  // Mencetak alamat email tujuan ke konsol
  console.log("to", to);

  // Membuat transporter menggunakan konfigurasi SMTP Gmail
  const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com", // Host SMTP Gmail
    port: 465, // Port SMTP untuk koneksi aman (SSL)
    secure: true, // Menggunakan SSL
    auth: {
      user: "", // Alamat email pengirim (harus diisi)
      pass: "", // Kata sandi atau token aplikasi untuk email pengirim (harus diisi)
    },
  });

  // Mengirim email menggunakan transporter yang telah dikonfigurasi
  const info = await transporter.sendMail({
    from: "", // Alamat email pengirim (harus diisi)
    to, // Alamat email tujuan
    subject, // Subjek email
    html, // Konten email dalam format HTML
  });

  // Memeriksa apakah email berhasil dikirim
  if (info.accepted[0] === to) {
    // Jika email berhasil dikirim, kembalikan status true dan pesan sukses
    return { status: true, msg: "Email sent successfully." };
  } else {
    // Jika email tidak berhasil dikirim, kembalikan status false dan pesan kesalahan
    return { status: false, msg: "Email not sent." };
  }
};

// Mengekspor fungsi sendMail agar dapat digunakan di file lain
module.exports = sendMail;
```

# CRUD Flutter

## 1. Register

Saya membuat form register yang berisi username, email, password, dan metode OTP. Berikut adalah code yang saya buat untuk form register.

```dart
  // Fungsi asinkron untuk menangani proses registrasi
  Future<void> _register() async {
    // Mengambil nilai dari TextField untuk username
    final String username = _usernameController.text;
    // Mengambil nilai dari TextField untuk email
    final String email = _emailController.text;
    // Mengambil nilai dari TextField untuk password
    final String password = _passwordController.text;

    // Mengirim permintaan POST ke server untuk registrasi
    final response = await http.post(
      Uri.parse('http://192.168.0.105:3000/register'), // URL endpoint registrasi
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', // Header untuk tipe konten
      },
      body: jsonEncode(<String, String>{
        'username': username, // Mengirim username
        'email': email, // Mengirim email
        'password': password, // Mengirim password
        'otpMethod': _selectedOtpMethod, // Mengirim metode OTP yang dipilih
      }),
    );

    // Mendekode respons dari server
    final responseBody = jsonDecode(response.body);

    // Jika status kode respons adalah 201 (Created)
    if (response.statusCode == 201) {
      // Menampilkan pesan sukses menggunakan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
      // Navigasi ke halaman OTP Verification dengan membawa username
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(username: username),
        ),
      );
    } else {
      // Menampilkan pesan kesalahan menggunakan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: ${responseBody['message']}')),
      );
    }
  }

```

## 2. Verify OTP

Saya membuat form verifikasi OTP yang berisi username dan OTP. Berikut adalah code yang saya buat untuk form verifikasi OTP.

```dart
// Mengimpor paket Flutter Material untuk membuat UI
import 'package:flutter/material.dart';
// Mengimpor paket http untuk melakukan permintaan HTTP
import 'package:http/http.dart' as http;
// Mengimpor dart:convert untuk mendekode dan mengenkode data JSON
import 'dart:convert';

// Mendefinisikan kelas StatefulWidget untuk halaman verifikasi OTP
class OtpVerificationPage extends StatefulWidget {
  final String username; // Mendeklarasikan variabel final untuk menyimpan username

  // Konstruktor untuk menerima username sebagai parameter
  const OtpVerificationPage({super.key, required this.username});

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

// Mendefinisikan kelas State untuk OtpVerificationPage
class _OtpVerificationPageState extends State<OtpVerificationPage> {
  // Membuat controller untuk TextField OTP
  final TextEditingController _otpController = TextEditingController();

  // Fungsi asinkron untuk memverifikasi OTP
  Future<void> _verifyOtp() async {
    final String otp = _otpController.text; // Mengambil nilai OTP dari TextField

    // Mengirim permintaan POST ke server untuk verifikasi OTP
    final response = await http.post(
      Uri.parse('http://192.168.0.105:3000/verify-otp'), // URL endpoint verifikasi OTP
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', // Header untuk tipe konten
      },
      body: jsonEncode(<String, String>{
        'username': widget.username, // Mengirim username
        'otp': otp, // Mengirim OTP
      }),
    );

    final responseBody = jsonDecode(response.body); // Mendekode respons dari server

    // Jika status kode respons adalah 200 (OK)
    if (response.statusCode == 200) {
      // Menampilkan pesan sukses menggunakan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
      // Navigasi ke halaman login
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Menampilkan pesan kesalahan menggunakan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify OTP: ${responseBody['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Mengatur warna latar belakang Scaffold
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Padding horizontal
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Menyusun widget di tengah secara vertikal
              children: <Widget>[
                Image.asset(
                  'images/logo.jpg', // Menampilkan gambar logo
                  width: 200, // Lebar gambar
                ),
                const SizedBox(height: 30), // Jarak vertikal
                const Align(
                  alignment: Alignment.centerLeft, // Menyusun teks di kiri
                  child: Text(
                    'Enter OTP', // Teks judul
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Gaya teks
                  ),
                ),
                const SizedBox(height: 20), // Jarak vertikal
                TextField(
                  controller: _otpController, // Menghubungkan TextField dengan controller
                  decoration: InputDecoration(
                    labelText: 'OTP', // Label untuk TextField
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Radius border
                      borderSide: const BorderSide(color: Colors.blueAccent), // Warna border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Radius border saat fokus
                      borderSide: const BorderSide(color: Colors.blue), // Warna border saat fokus
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10), // Padding konten
                  ),
                ),
                const SizedBox(height: 20), // Jarak vertikal
                SizedBox(
                  width: double.infinity, // Lebar penuh
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15), // Padding tombol
                      backgroundColor: Colors.blue, // Warna latar belakang tombol
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Radius border tombol
                      ),
                    ),
                    onPressed: _verifyOtp, // Fungsi yang dipanggil saat tombol ditekan
                    child: const Text('Verify OTP',
                        style: TextStyle(fontSize: 18)), // Teks tombol
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
```

## 3. Login

Saya membuat form login yang berisi username atau email dan password. Berikut adalah code yang saya buat untuk form login.

```dart
  // Fungsi asinkron untuk menangani proses registrasi
  Future<void> _register() async {
    // Mengambil nilai dari TextField untuk username
    final String username = _usernameController.text;
    // Mengambil nilai dari TextField untuk email
    final String email = _emailController.text;
    // Mengambil nilai dari TextField untuk password
    final String password = _passwordController.text;

    // Mencetak pesan ke konsol untuk debugging
    print('Starting registration process...');
    print('Username: $username, Email: $email, Password: $password');

    // Mengirim permintaan POST ke server untuk registrasi
    final response = await http.post(
      Uri.parse('http://192.168.0.105:3000/register'), // URL endpoint registrasi
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', // Header untuk tipe konten
      },
      body: jsonEncode(<String, String>{
        'username': username, // Mengirim username
        'email': email, // Mengirim email
        'password': password, // Mengirim password
        'otpMethod': _selectedOtpMethod, // Mengirim metode OTP yang dipilih
      }),
    );

    // Mendekode respons dari server
    final responseBody = jsonDecode(response.body);

    // Jika status kode respons adalah 201 (Created)
    if (response.statusCode == 201) {
      // Menampilkan pesan sukses menggunakan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
      // Navigasi ke halaman OTP Verification dengan membawa username
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(username: username),
        ),
      );
    } else {
      // Menampilkan pesan kesalahan menggunakan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: ${responseBody['message']}')),
      );
    }
  }
```

[Flutter](https://docs.flutter.dev/cookbook/networking/fetch-data)
[Http](https://pub.dev/packages/http)
[Fetching Data from API: HTTP GET Request in Flutter](https://medium.com/@rijalprabesh145/fetching-data-from-api-http-get-request-in-flutter-7da19389651d)
