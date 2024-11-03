import 'package:flutter/material.dart';

import '../widgets/unfurl_list_tile.dart';
import 'add_edit_tag_screen.dart';

class TagScreen extends StatelessWidget {
  const TagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          // Hero Image Section with Overlay Text and Button
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Image with dark overlay
              Container(
                height: height * 0.6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  image: DecorationImage(
                    image: const NetworkImage(
                        'https://images.unsplash.com/photo-1516259762381-22954d7d3ad2'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.6),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
              // Content overlay
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tag List',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddEditTagScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add new',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Links List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              children: const [
                UnfurlListTile(title: 'Gregs Birthday'),
                Divider(height: 1),
                UnfurlListTile(title: 'Recipes'),
                Divider(height: 1),
                UnfurlListTile(title: 'Travel'),
                Divider(height: 1),
                // Add more links as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}
