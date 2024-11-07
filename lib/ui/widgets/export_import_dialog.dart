import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/link.dart';
import '../../data/models/tag.dart';
import '../../states/export_import_provider.dart';
import '../screens/import_screen.dart';

class ExportDialog extends ConsumerWidget {
  const ExportDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportImportService = ref.watch(exportImportServiceProvider);

    return AlertDialog(
      title: const Text('Export Data'),
      content: const Text(
        'Are you sure you want to export all your data to a CSV file? '
        'This will include all your links and tags.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            try {
              String path = await exportImportService.exportData(context);
              if (context.mounted) {
                Navigator.of(context).pop(); // Close dialog first
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Data exported to: $path'),
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {},
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.of(context).pop(); // Close dialog first
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Export failed: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text('Export'),
        ),
      ],
    );
  }
}

class ImportDialog extends ConsumerWidget {
  const ImportDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportImportService = ref.watch(exportImportServiceProvider);

    return AlertDialog(
      title: const Text('Import Data'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Please select a CSV file to import.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Note: This will add new records to your existing data. '
            'Make sure your CSV file follows the correct format.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              Map<Tag, List<UnfurlLink>> importedData =
                  await exportImportService.importData(context);
              if (importedData.isNotEmpty) {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImportScreen(
                      importData: importedData,
                      onImport: (data) {
                        exportImportService.insertData(data, context);
                      },
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No data found in the file'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              // if (context.mounted) {
              //   Navigator.of(context).pop(); // Close dialog first
              //   ref.read(linksProvider.notifier).loadLinks();
              //   ref.read(tagsProvider.notifier).loadTags();
              //
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(
              //       content: Text('Data imported successfully'),
              //       backgroundColor: Colors.green,
              //     ),
              //   );
              // }
            } catch (e) {
              if (context.mounted) {
                Navigator.of(context).pop(); // Close dialog first
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Import failed: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text('Choose File'),
        ),
      ],
    );
  }
}
