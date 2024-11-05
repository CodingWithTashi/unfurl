import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? res = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const QrCodeScreen()));
          if (res != null) {
            ref.read(qrCodeScannerServiceProvider).processQRCodeData(res);
          }
        },
        child: const Icon(Icons.qr_code),
      ),
    );
  }
}
