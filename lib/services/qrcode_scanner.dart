import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unfurl/services/link_database_service.dart';

import '../data/models/link.dart';
import '../data/models/qr_code_data.dart';
import '../data/models/tag.dart';
import '../states/link_provider.dart';

final qrCodeScannerServiceProvider = Provider((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return QRCodeScannerService(databaseService);
});

class QRCodeScannerService {
  final DatabaseService databaseService;

  QRCodeScannerService(this.databaseService);

  QRCodeData parseQRCodeData(String qrCodeData) {
    final parts = qrCodeData.split('||');
    return QRCodeData(
      packageName: parts[0],
      type: parts[1],
      id: parts[2],
      title: parts[3],
      description: parts[4],
      link: parts[5],
      createdDate: sqliteToDateTime(parts[6]),
      updatedDate: sqliteToDateTime(parts[7]),
      status: parts[8],
      tagId: int.parse(parts[9]),
      tagName: parts[10],
      tagDescription: parts[11],
      tagCreatedDate: sqliteToDateTime(parts[12]),
      tagUpdatedDate: sqliteToDateTime(parts[13]),
      tagStatus: parts[14],
    );
  }

  Future<void> saveToDatabase(QRCodeData data) async {
    if (data.type == 'Tag') {
      if (data.id != 'null') {
        await databaseService.insertTag(
          Tag(
            id: int.parse(data.id),
            tagName: data.tagName ?? 'Unknown',
            tagDescription: data.tagDescription ?? 'Unknown',
            createdDate: data.createdDate ?? DateTime.now(),
            updatedDate: data.updatedDate ?? DateTime.now(),
            status: data.status ?? 'active',
          ),
        );
      }
    } else if (data.type == 'Link') {
      if (data.id != 'null' || data.id != '') {
        await databaseService.insertLink(
          UnfurlLink(
            id: int.parse(data.id),
            title: data.title ?? 'Unknown',
            description: data.description ?? 'Unknown',
            link: data.link ?? '',
            createdDate: data.createdDate ?? DateTime.now(),
            updatedDate: data.updatedDate ?? DateTime.now(),
            status: data.status ?? 'active',
            tagId: data.tagId,
          ),
        );
        if (data.tagId != null || data.tagId != '') {
          await databaseService.insertTag(
            Tag(
              id: data.tagId,
              tagName: data.tagName ?? 'Unknown',
              tagDescription: data.tagDescription ?? 'Unknown',
              createdDate: data.tagCreatedDate ?? DateTime.now(),
              updatedDate: data.tagUpdatedDate ?? DateTime.now(),
              status: data.tagStatus ?? 'active',
            ),
          );
        }
      }
    }
  }

  DateTime sqliteToDateTime(String dateTimeString) {
    return DateTime.parse(
        dateTimeString); // Converts 'YYYY-MM-DDTHH:MM:SS.sss' back to DateTime
  }
}
