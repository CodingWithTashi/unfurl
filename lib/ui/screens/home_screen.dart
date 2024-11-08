import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unfurl/data/models/link.dart';
import 'package:unfurl/data/models/tag.dart';
import 'package:unfurl/states/link_provider.dart';
import 'package:unfurl/states/tag_provider.dart';
import 'package:unfurl/states/widgets/bottom_nav_bar/bottom_nav_bar_state.dart';
import 'package:unfurl/ui/screens/add_edit_link_screen.dart';
import 'package:unfurl/ui/screens/add_edit_tag_screen.dart';
import 'package:unfurl/ui/widgets/home_screen/link_card.dart';
import 'package:unfurl/ui/widgets/home_screen/tag_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                  height: height * 0.42,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    image: DecorationImage(
                      image: const AssetImage('assets/img/icon_cover.png'),
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
                  ],
                ),
              ),
            ],
          ),

          // Links List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.read(linksProvider.notifier).loadLinks();
                ref.read(tagsProvider.notifier).loadTags();
              },
              child: ListView(
                padding: const EdgeInsets.all(5),
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final tags = ref.watch(tagsProvider);
                      Tag? latestTag = tags.firstOrNull;

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
                        onViewAll: () {
                          ref
                              .read(bottomNavProvider.notifier)
                              .setAndPersistValue(2);
                        },
                        onAdd: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return AddEditTagScreen();
                            },
                          ));
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Consumer(
                    builder: (context, ref, child) {
                      final links = ref.watch(linksProvider);
                      UnfurlLink? latestLink = links.firstOrNull;

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
                        onViewAll: () {
                          ref
                              .read(bottomNavProvider.notifier)
                              .setAndPersistValue(1);
                        },
                        onAdd: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return AddEditLinkScreen();
                            },
                          ));
                        },
                      );
                    },
                  )
                ],
              ),
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
