import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unfurl/data/models/tag.dart';

import '../../states/tag_provider.dart';
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
                    image: const AssetImage('assets/img/ic_launcher.png'),
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
            child: Consumer(
              builder: (context, ref, child) {
                List<Tag> tags = ref.watch(tagsProvider);
                if (tags.isEmpty) {
                  return Center(
                    child: Text('No tags found, try adding some!'),
                  );
                }
                return ListView.builder(
                  itemCount: tags.length,
                  itemBuilder: (context, index) {
                    final tag = tags[index];
                    return ListTile(
                      title: Text(tag.tagName),
                      subtitle: Text(tag.tagDescription),
                      trailing: Text(tag.status),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditTagScreen(tag: tag),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
