// services/csv_service.dart
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../services/permission_service.dart';
import '../ui/widgets/permission_dialog.dart';

class CSVService {
  static Future<String> exportToCSV(
    List<Map<String, dynamic>> data,
    String fileName,
    BuildContext context,
  ) async {
    bool hasPermission = await PermissionService.hasStoragePermission();
    if (!hasPermission) {
      bool shouldShowRationale =
          await PermissionService.shouldShowPermissionRationale();

      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PermissionDialog(
            title: 'Storage Permission Required',
            message: shouldShowRationale
                ? 'We need storage permission to export your data to a CSV file.'
                : 'Please grant storage permission in settings to export data.',
            onRetry: () async {
              bool granted = await PermissionService.requestStoragePermission();
              if (!granted && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Permission denied')),
                );
              }
            },
            showOpenSettings: !shouldShowRationale,
          ),
        );
      }

      // Check permission again after dialog
      hasPermission = await PermissionService.hasStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission is required');
      }
    }

    try {
      List<List<dynamic>> csvData = [];
      if (data.isNotEmpty) {
        csvData.add(data.first.keys.toList());
      }
      for (var item in data) {
        csvData.add(item.values.toList());
      }

      String csv = const ListToCsvConverter().convert(csvData);

      String path;
      if (Platform.isAndroid) {
        final sdkVersion =
            int.parse(Platform.operatingSystemVersion.split('.').first);
        if (sdkVersion >= 33) {
          Directory appDir = await getApplicationDocumentsDirectory();
          path = '${appDir.path}/exports';
          await Directory(path).create(recursive: true);
        } else {
          Directory? directory = await getExternalStorageDirectory();
          path = directory?.path ??
              (await getApplicationDocumentsDirectory()).path;
        }
      } else {
        Directory appDir = await getApplicationDocumentsDirectory();
        path = appDir.path;
      }

      String filePath = '$path/$fileName';
      File file = File(filePath);
      await file.writeAsString(csv);
      return filePath;
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> importFromCSV(
      BuildContext context) async {
    bool hasPermission = await PermissionService.hasStoragePermission();
    if (!hasPermission) {
      bool shouldShowRationale =
          await PermissionService.shouldShowPermissionRationale();

      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PermissionDialog(
            title: 'Storage Permission Required',
            message: shouldShowRationale
                ? 'We need storage permission to import your CSV file.'
                : 'Please grant storage permission in settings to import data.',
            onRetry: () async {
              bool granted = await PermissionService.requestStoragePermission();
              if (!granted && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Permission denied')),
                );
              }
            },
            showOpenSettings: !shouldShowRationale,
          ),
        );
      }

      // Check permission again after dialog
      hasPermission = await PermissionService.hasStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission is required');
      }
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String csvString = await file.readAsString();

        List<List<dynamic>> csvTable =
            const CsvToListConverter().convert(csvString);
        if (csvTable.isEmpty) {
          throw Exception('CSV file is empty');
        }

        List<Map<String, dynamic>> data = [];
        List<String> headers = csvTable[0].map((e) => e.toString()).toList();

        for (int i = 1; i < csvTable.length; i++) {
          Map<String, dynamic> row = {};
          for (int j = 0; j < headers.length; j++) {
            if (j < csvTable[i].length) {
              row[headers[j]] = csvTable[i][j];
            } else {
              row[headers[j]] = '';
            }
          }
          data.add(row);
        }

        return data;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to import CSV: $e');
    }
  }
}
