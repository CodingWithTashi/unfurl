import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unfurl/states/link_provider.dart';
import 'package:unfurl/states/tag_provider.dart';
import 'package:unfurl/ui/screens/add_edit_link_screen.dart';
import 'package:unfurl/ui/screens/add_edit_tag_screen.dart';
import 'package:unfurl/ui/screens/link_screen.dart';
import 'package:unfurl/ui/widgets/home_screen/link_card.dart';
import 'package:unfurl/ui/widgets/home_screen/tag_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              Hero(
                tag: 'ic_launcher-hero-image',
                child: Container(
                  height: height * 0.5,
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
              ),
              // Content overlay
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Welcome to Unfurl',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),

          // Links List
          Expanded(
            child: Column(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final latestTagStream = ref.watch(latestTagProvider);

                    return latestTagStream.when(
                      data: (latestTag) {
                        if (latestTag != null) {
                          return LatestTagCard(
                            latestTag: latestTag,
                            onEdit: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return AddEditTagScreen(
                                    tag: latestTag,
                                  );
                                },
                              ));
                            },
                            onDelete: () async {
                              final shouldDelete =
                                  await _showDeleteConfirmation(context, 'Tag');
                              if (shouldDelete && latestTag.id != null) {
                                ref
                                    .read(linksProvider.notifier)
                                    .deleteLink(latestTag.id!);
                              }
                            },
                            onViewAll: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return LinkScreen();
                              }));
                            },
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stackTrace) => Text('Error: $error'),
                    );
                  },
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final latestLinkStream = ref.watch(latestLinkProvider);

                    return latestLinkStream.when(
                      data: (latestLink) {
                        if (latestLink != null) {
                          return LatestLinkCard(
                            latestLink: latestLink,
                            onEdit: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return AddEditLinkScreen(
                                    link: latestLink,
                                  );
                                },
                              ));
                            },
                            onDelete: () async {
                              final shouldDelete =
                                  await _showDeleteConfirmation(
                                      context, 'Link');
                              if (shouldDelete && latestLink.id != null) {
                                ref
                                    .read(linksProvider.notifier)
                                    .deleteLink(latestLink.id!);
                              }
                            },
                            onViewAll: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return LinkScreen();
                              }));
                            },
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stackTrace) => Text('Error: $error'),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(
      BuildContext context, String title) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: Text('Are you sure you want to delete this ${title}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
