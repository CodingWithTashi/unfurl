import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unfurl/services/tag_database_service.dart';

import '../data/models/link.dart';
import '../data/models/tag.dart';
import 'link_database_service.dart';

class ExportImportService {
  final DatabaseService _databaseService;
  final TagDatabaseService _tagDatabaseService;

  ExportImportService(this._databaseService, this._tagDatabaseService);

  Future<String> exportData(BuildContext context) async {
    try {
      // Get all data
      List<UnfurlLink> links = await _databaseService.getAllLinks();
      List<Tag> tags = await _tagDatabaseService.getAllTags();

      // Define headers for CSV
      final headers = [
        'type',
        'id',
        'title',
        'description',
        'link',
        'tagName',
        'tagDescription',
        'createdDate',
        'updatedDate',
        'status'
      ];

      // Convert to CSV format
      List<Map<String, String>> exportData = [];

      // Add links
      for (var link in links) {
        exportData.add({
          'type': 'link',
          'id': link.id?.toString() ?? '',
          'title': _escapeCsvField(link.title),
          'description': _escapeCsvField(link.description),
          'link': _escapeCsvField(link.link),
          'tagName': '', // Empty for links
          'tagDescription': '', // Empty for links
          'createdDate': link.createdDate.toIso8601String(),
          'updatedDate': link.updatedDate.toIso8601String(),
          'status': link.status,
        });
      }

      // Add tags
      for (var tag in tags) {
        exportData.add({
          'type': 'tag',
          'id': tag.id?.toString() ?? '',
          'title': '', // Empty for tags
          'description': '', // Empty for tags
          'link': '', // Empty for tags
          'tagName': _escapeCsvField(tag.tagName),
          'tagDescription': _escapeCsvField(tag.tagDescription),
          'createdDate': tag.createdDate.toIso8601String(),
          'updatedDate': tag.updatedDate.toIso8601String(),
          'status': tag.status,
        });
      }

      // Convert to CSV string
      String csvContent = headers.join(',') + '\n';
      for (var row in exportData) {
        csvContent += headers
                .map((header) => _escapeCsvField(row[header] ?? ''))
                .join(',') +
            '\n';
      }

      // Get the downloads directory
      String? downloadsPath;

      if (Platform.isAndroid) {
        // For Android, use external storage directory
        Directory externalStorageFolder =
            Directory('/storage/emulated/0/Download');
        downloadsPath = externalStorageFolder.path;
        // Create Downloads directory if it doesn't exist
        final downloadsDir = Directory(downloadsPath);
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
      } else if (Platform.isIOS) {
        // For iOS, use documents directory
        final directory = await getApplicationDocumentsDirectory();
        downloadsPath = directory.path;
      }

      if (downloadsPath == null) {
        throw Exception('Could not access downloads directory');
      }

      // Generate timestamp for unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$downloadsPath/data_export_$timestamp.csv';

      // Save the CSV file
      final file = File(filePath);
      await file.writeAsString(csvContent);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File exported to: $filePath'),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      return filePath;
    } catch (e, stackTrace) {
      print('Export error: $e');
      print('Stack trace: $stackTrace');

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      throw Exception('Failed to export data: ${e.toString()}');
    }
  }

  Future<void> importData(BuildContext context) async {
    try {
      final file = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (file == null) throw Exception('No file selected');

      final content = await File(file.files.single.path!).readAsString();
      final lines = content.split('\n');
      if (lines.isEmpty) throw Exception('Empty file');

      final headers = lines[0].split(',');
      final headerMap = {
        for (var i = 0; i < headers.length; i++) headers[i]: i
      };

      for (var i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;

        final values = _parseCsvLine(lines[i]);
        final type = values[headerMap['type']!];

        if (type == 'link') {
          await _databaseService.insertLink(UnfurlLink(
            id: int.tryParse(values[headerMap['id']!]),
            title: values[headerMap['title']!],
            description: values[headerMap['description']!],
            link: values[headerMap['link']!],
            createdDate: DateTime.parse(values[headerMap['createdDate']!]),
            updatedDate: DateTime.parse(values[headerMap['updatedDate']!]),
            status: values[headerMap['status']!],
          ));
        } else if (type == 'tag') {
          await _tagDatabaseService.insertTag(Tag(
            id: int.tryParse(values[headerMap['id']!]),
            tagName: values[headerMap['tagName']!],
            tagDescription: values[headerMap['tagDescription']!],
            createdDate: DateTime.parse(values[headerMap['createdDate']!]),
            updatedDate: DateTime.parse(values[headerMap['updatedDate']!]),
            status: values[headerMap['status']!],
          ));
        }
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data imported successfully'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Import error: $e');
      print('Stack trace: $stackTrace');

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      throw Exception('Failed to import data: ${e.toString()}');
    }
  }

  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  List<String> _parseCsvLine(String line) {
    List<String> result = [];
    bool inQuotes = false;
    StringBuffer currentField = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      if (line[i] == '"') {
        if (i + 1 < line.length && line[i + 1] == '"') {
          currentField.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (line[i] == ',' && !inQuotes) {
        result.add(currentField.toString());
        currentField.clear();
      } else {
        currentField.write(line[i]);
      }
    }
    result.add(currentField.toString());
    return result;
  }
}
