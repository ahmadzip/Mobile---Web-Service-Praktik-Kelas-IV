import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final String email;

  const DashboardPage({super.key, required this.username, required this.email});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    FlutterDownloader.initialize();
    _fetchProducts();
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _fetchProducts() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.0.105:3000/products'));
      if (response.statusCode == 200) {
        final List<dynamic> productJson = jsonDecode(response.body);
        setState(() {
          products = productJson.map((json) => Product.fromJson(json)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load products: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e')),
      );
    }
  }

  Future<void> _createQris(Product product) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.105:3000/create-qris'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'sku': product.sku,
        'email': widget.email,
      }),
    );

    // Log the response body and email for debugging
    print('Response body: ${response.body}');
    print('Email sent: ${widget.email}');

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 && responseBody['qris_url'] != null) {
      final String qrisUrl = responseBody['qris_url'];
      _showQrisDialog(qrisUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to create QRIS: ${responseBody['message']}')),
      );
    }
  }

  void _showQrisDialog(String qrisUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QRIS Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(qrisUrl),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final status = await Permission.storage.request();
                  if (status.isGranted) {
                    final taskId = await FlutterDownloader.enqueue(
                      url: qrisUrl,
                      savedDir: '/storage/emulated/0/Download',
                      fileName: 'qris.png',
                      showNotification: true,
                      openFileFromNotification: true,
                    );
                    if (taskId != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Image downloaded successfully')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Permission denied to download image')),
                    );
                  }
                },
                child: const Text('Download QR Code'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  backgroundImage: Image.network(
                    "https://ui-avatars.com/api/?name=${widget.username}?size=100",
                  ).image,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.username,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.email,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Selamat Pagi',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Image.asset(
              'images/carousell.jpg',
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
                                const SizedBox(height: 5),
                                Text(
                                  'SKU: ${product.sku}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Rp${product.price}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: () => _createQris(product),
                              ),
                            ],
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
  final String sku;
  final String name;
  final String description;
  final String imageUrl;
  final int price;

  Product({
    required this.sku,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      sku: json['sku'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: json['price'],
    );
  }
}
