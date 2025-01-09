import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    _fetchProducts();
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.0.105:3000/user-products/${widget.email}'));
      if (response.statusCode == 200) {
        final List<dynamic> productJson = jsonDecode(response.body);

        setState(() {
          products = productJson
              .map((json) => Product.fromJson(json))
              .toList()
              .cast<Product>();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load products: ${response.reasonPhrase}')),
        );
      }
    } catch (e, stackTrace) {
      print('Error fetching products: $e');
      print('StackTrace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e')),
      );
    }
  }

  Future<void> _createQris(Product product) async {
    if (product.owned) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(product: product),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.105:3000/create-qris'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'emailOrUsername': widget.email,
          'productId': product.sku,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        print('Response body: $responseBody');

        if (responseBody.containsKey('qris_url')) {
          final Map<String, dynamic> qrisUrlMap = responseBody['qris_url'];
          if (qrisUrlMap.containsKey('qris_url')) {
            final String qrisUrl = qrisUrlMap['qris_url'];
            _showQrisDialog(qrisUrl);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Failed to create QRIS: Invalid QRIS URL format')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to create QRIS: ${responseBody['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to create QRIS: ${response.reasonPhrase}')),
        );
      }
    } catch (e, stackTrace) {
      print('Error creating QRIS: $e');
      print('StackTrace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create QRIS: $e')),
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
    ).then((_) {
      // Refresh products after the dialog is closed
      _fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'CourseConnect',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            'https://i.ibb.co/r5r1vRL/logo.png', // Updated image URL
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(email: widget.email),
                ),
              );
            },
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    "https://ui-avatars.com/api/?name=${widget.username}&size=100",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.username,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.email,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Selamat Pagi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (products.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            ...products.map((product) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromRGBO(0, 0, 0, 0.15),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Price: Rp${product.price}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
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
                              borderRadius: BorderRadius.circular(1000),
                            ),
                          ),
                          onPressed: () => _createQris(product),
                          child: Text(
                            product.owned ? 'Lihat Course' : 'Beli Course',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
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
  final bool owned;

  Product({
    required this.sku,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.owned,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      sku: json['sku'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: json['price'],
      owned: json['owned'] ?? false, // Provide a default value for owned
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product.imageUrl),
            const SizedBox(height: 10),
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Price: Rp${product.price}',
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(
              product.description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final String email;

  const EditProfilePage({super.key, required this.email});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _deleteAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.0.105:3000/delete/${widget.email}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print('Response: ${response.body}');
      if (response.statusCode == 200) {
        Navigator.pop(context); // Navigate back to the previous screen
        _logout();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to delete account: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete your account?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteAccount(); // Call the delete account method
              },
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
        title: const Text('Edit Profile'),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmDeleteAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
