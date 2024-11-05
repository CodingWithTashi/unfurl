import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final bool showOpenSettings;

  const PermissionDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.showOpenSettings = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 20),
          if (showOpenSettings)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          if (!showOpenSettings)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Grant Permission'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
