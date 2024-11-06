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

  QRCodeData parseQRCodeData(String qrCodeData) {
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
      createdDate: sqliteToDateTime(parts[8]),
      updatedDate: sqliteToDateTime(parts[9]),
      status: parts[10],
    );
  }

  Future<void> saveToDatabase(QRCodeData data) async {
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

  DateTime sqliteToDateTime(String dateTimeString) {
    return DateTime.parse(
        dateTimeString); // Converts 'YYYY-MM-DDTHH:MM:SS.sss' back to DateTime
  }
}
