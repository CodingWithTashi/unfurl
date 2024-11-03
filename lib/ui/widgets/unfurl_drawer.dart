import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/widgets/bottom_nav_bar/bottom_nav_bar_state.dart';

class UnfurlDrawer extends ConsumerWidget {
  const UnfurlDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Unfurl',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.home_outlined,
                  ),
                  title: const Text(
                    'Home',
                  ),
                  onTap: () {
                    ref.read(bottomNavProvider.notifier).setAndPersistValue(0);
                    Navigator.pop(context);
                    // Handle navigation
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.link,
                  ),
                  title: const Text(
                    'Links',
                  ),
                  onTap: () {
                    ref.read(bottomNavProvider.notifier).setAndPersistValue(1);
                    Navigator.pop(context);
                    // Handle navigation
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.local_offer_outlined,
                  ),
                  title: const Text(
                    'Tags',
                  ),
                  onTap: () {
                    ref.read(bottomNavProvider.notifier).setAndPersistValue(2);
                    Navigator.pop(context);
                    // Handle navigation
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.file_upload_outlined,
                  ),
                  title: const Text(
                    'Export Tags',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle export
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.file_download_outlined,
                  ),
                  title: const Text(
                    'Import Tags',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle import
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
