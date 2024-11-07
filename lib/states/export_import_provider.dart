import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/export_import_service.dart';
import 'link_provider.dart';

final exportImportServiceProvider = Provider((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return ExportImportService(databaseService);
});
