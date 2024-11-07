import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/link.dart';
import '../data/models/tag.dart';
import 'link_database_service.dart';

class ExportImportService {
  final DatabaseService _databaseService;

  ExportImportService(
    this._databaseService,
  );

  Future<String> exportData(BuildContext context) async {
    try {
      // Get all data
      List<UnfurlLink> links = await _databaseService.getAllLinksWithTags();
      List<Tag> tags = await _databaseService.getAllTags();

      // Define headers for CSV
      final headers = [
        'Type',
        'ID',
        'Title',
        'Description',
        'Link',
        'Tag Name',
        'Tag Description',
        'Created Date',
        'Updated Date',
        'Status',
      ];

      // Convert to CSV format
      List<Map<String, String>> exportData = [];

      // Add tags and their associated links
      for (var tag in tags) {
        exportData.add({
          'Type': 'Tag',
          'ID': tag.id?.toString() ?? '',
          'Title': '', // Empty for tags
          'Description': '', // Empty for tags
          'Link': '', // Empty for tags
          'Tag Name': _escapeCsvField(tag.tagName),
          'Tag Description': _escapeCsvField(tag.tagDescription),
          'Created Date': tag.createdDate.toIso8601String(),
          'Updated Date': tag.updatedDate.toIso8601String(),
          'Status': tag.status,
        });

        // Add associated links for the tag
        for (var link in links.where((l) => l.tagId == tag.id)) {
          exportData.add({
            'Type': 'Link',
            'ID': link.id?.toString() ?? '',
            'Title': _escapeCsvField(link.title),
            'Description': _escapeCsvField(link.description),
            'Link': _escapeCsvField(link.link),
            'Tag Name': _escapeCsvField(tag.tagName),
            'Tag Description': _escapeCsvField(tag.tagDescription),
            'Created Date': link.createdDate.toIso8601String(),
            'Updated Date': link.updatedDate.toIso8601String(),
            'Status': link.status,
          });
        }
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
      String? downloadsPath = await _getDownloadsPath();
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

  Future<Map<Tag, List<UnfurlLink>>> importData(BuildContext context) async {
    Map<Tag, List<UnfurlLink>> importData = {};
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
        final type = values[headerMap['Type']!];

        if (type == 'Tag') {
          final tagId = int.tryParse(values[headerMap['ID']!]);
          final tag = Tag(
            id: tagId,
            tagName: values[headerMap['Tag Name']!],
            tagDescription: values[headerMap['Tag Description']!],
            createdDate: DateTime.parse(values[headerMap['Created Date']!]),
            updatedDate: DateTime.parse(values[headerMap['Updated Date']!]),
            status: values[headerMap['Status']!],
          );
          importData[tag] = [];
        } else if (type == 'Link') {
          final linkId = int.tryParse(values[headerMap['ID']!]);
          final link = UnfurlLink(
            id: linkId,
            title: values[headerMap['Title']!],
            description: values[headerMap['Description']!],
            link: values[headerMap['Link']!],
            createdDate: DateTime.parse(values[headerMap['Created Date']!]),
            updatedDate: DateTime.parse(values[headerMap['Updated Date']!]),
            status: values[headerMap['Status']!],
            tagId: (await _databaseService
                    .getTagByName(values[headerMap['Tag Name']!]))
                ?.id,
          );
          final tag = importData.keys.firstWhere(
            (tag) => tag.tagName == values[headerMap['Tag Name']!],
            orElse: () =>
                throw Exception('Tag not found for link: ${link.title}'),
          );
          importData[tag]!.add(link);
        }
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

    return importData;
  }

  Future<String?> _getDownloadsPath() async {
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

    return downloadsPath;
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

  Future<void> insertData(
      Map<Tag, List<UnfurlLink>> selectedData, BuildContext context) async {
    try {
      for (final entry in selectedData.entries) {
        final tag = entry.key;
        final links = entry.value;

        // Update existing tag or create a new one
        var existingTag = await _databaseService.getTagByName(tag.tagName);
        if (existingTag != null) {
          // Update existing tag
          await _databaseService.updateTag(existingTag.copyWith(
            tagName: tag.tagName,
            tagDescription: tag.tagDescription,
            createdDate: tag.createdDate,
            updatedDate: tag.updatedDate,
            status: tag.status,
          ));
        } else {
          // Create a new tag
          await _databaseService.insertTag(tag);
          existingTag = tag;
        }

        // Import associated links for the tag
        for (final link in links) {
          // Update existing link or create a new one
          var existingLink = await _databaseService.getLinkById(link.id!);
          if (existingLink != null) {
            // Update existing link
            await _databaseService.updateLink(existingLink.copyWith(
              title: link.title,
              description: link.description,
              link: link.link,
              createdDate: link.createdDate,
              updatedDate: link.updatedDate,
              status: link.status,
              tagId: existingTag.id,
            ));
          } else {
            // Create a new link
            await _databaseService
                .insertLink(link.copyWith(tagId: existingTag.id));
          }
        }
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data imported successfully'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      print('Import error: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
