import 'package:flutter/material.dart';

class OurLecturers extends StatelessWidget {
  const OurLecturers({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Our Lecturers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                LecturerCard(
                  imageUrl: 'https://via.placeholder.com/150',
                  name: 'Dr. John Doe',
                ),
                LecturerCard(
                  imageUrl: 'https://via.placeholder.com/150',
                  name: 'Dr. John Doe',
                ),
                LecturerCard(
                  imageUrl: 'https://via.placeholder.com/150',
                  name: 'Dr. John Doe',
                ),
                LecturerCard(
                  imageUrl: 'https://via.placeholder.com/150',
                  name: 'Dr. Jane Smith',
                ),
                LecturerCard(
                  imageUrl: 'https://via.placeholder.com/150',
                  name: 'Dr. Emily Johnson',
                ),
                // Add more LecturerCard widgets as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LecturerCard extends StatelessWidget {
  final String imageUrl;
  final String name;

  const LecturerCard({
    required this.imageUrl,
    required this.name,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50, // Adjust radius as needed
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
