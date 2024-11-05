import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unfurl/services/link_database_service.dart';
import 'package:unfurl/services/tag_database_service.dart';

import '../data/models/link.dart';
import '../data/models/qr_code_data.dart';
import '../data/models/tag.dart';
import '../states/link_provider.dart';
import '../states/tag_provider.dart';

final qrCodeScannerServiceProvider = Provider((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  final tagDatabaseService = ref.watch(tagDatabaseServiceProvider);
  return QRCodeScannerService(databaseService, tagDatabaseService);
});

class QRCodeScannerService {
  final DatabaseService databaseService;
  final TagDatabaseService tagDatabaseService;

  QRCodeScannerService(this.databaseService, this.tagDatabaseService);

  Future<void> processQRCodeData(String qrCodeData) async {
    final data = _parseQRCodeData(qrCodeData);
    if (data.packageName != null && data.packageName != 'com.greg.unfurl') {
      return;
    }
    await _saveToDatabase(data);
  }

  QRCodeData _parseQRCodeData(String qrCodeData) {
    final parts = qrCodeData.split('||');
    return QRCodeData(
      packageName: parts[0],
      type: parts[1],
      id: parts[2],
      title: parts[3],
      description: parts[4],
      link: parts[5],
      tagName: parts[6],
      tagDescription: parts[7],
      createdDate: DateTime.parse(parts[8]),
      updatedDate: DateTime.parse(parts[9]),
      status: parts[10],
    );
  }

  Future<void> _saveToDatabase(QRCodeData data) async {
    if (data.type == 'Tag') {
      await tagDatabaseService.insertTag(
        Tag(
          id: int.parse(data.id),
          tagName: data.tagName,
          tagDescription: data.tagDescription,
          createdDate: data.createdDate,
          updatedDate: data.updatedDate,
          status: data.status,
        ),
      );
    } else if (data.type == 'Link') {
      await databaseService.insertLink(
        UnfurlLink(
          id: int.parse(data.id),
          title: data.title,
          description: data.description,
          link: data.link,
          createdDate: data.createdDate,
          updatedDate: data.updatedDate,
          status: data.status,
        ),
      );
    }
  }
}
