import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unfurl/states/link_provider.dart';
import 'package:unfurl/states/tag_provider.dart';
import 'package:unfurl/ui/screens/qr_code_screen.dart';

import '../../services/qrcode_scanner.dart';
import '../../states/widgets/bottom_nav_bar/bottom_nav_bar_state.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/unfurl_drawer.dart';
import 'home_screen.dart';
import 'link_screen.dart';
import 'tag_screen.dart';

class SkeletonScreen extends ConsumerStatefulWidget {
  const SkeletonScreen({super.key});

  @override
  ConsumerState createState() => _SkeletonScreenState();
}

class _SkeletonScreenState extends ConsumerState<SkeletonScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final int? navIndex = ref.watch(bottomNavProvider) as int?;
    const List<Widget> pageNavigation = <Widget>[
      HomeScreen(),
      LinkScreen(),
      TagScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Unfurl'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),

      /// When switching between tabs this will fade the old
      /// layout out and the new layout in.
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pageNavigation.elementAt(navIndex ?? 0),
      ),

      bottomNavigationBar: const BottomNavBar(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: UnfurlDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        tooltip: 'Add Links/Tags',
        onPressed: () async {
          String? res = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const QrCodeScreen()));
          if (res != null) {
            final data =
                ref.read(qrCodeScannerServiceProvider).parseQRCodeData(res);
            if (data.packageName != null &&
                data.packageName != 'com.greg.unfurl') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invalid QR Code'),
                  duration: const Duration(seconds: 1),
                ),
              );
              return;
            }
            // show confirmation dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('QR Code Detected'),
                  content: Text(
                      'Do you want to save this ${data.type} to your collection?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await ref
                              .read(qrCodeScannerServiceProvider)
                              .saveToDatabase(data);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Saved ${data.type} to collection'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                          ref.read(tagsProvider.notifier).loadTags();
                          ref.read(linksProvider.notifier).loadLinks();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to save ${data.type} to collection, Check qr code'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }

                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
            );
          }
        },
        label: Text('Add'),
        icon: const Icon(Icons.qr_code),
      ),
    );
  }
}
