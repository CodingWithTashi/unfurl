import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      final sdkVersion =
          int.parse(Platform.operatingSystemVersion.split('.').first);
      if (sdkVersion >= 33) {
        final photos = await Permission.photos.status;
        return photos.isGranted;
      } else {
        final storage = await Permission.storage.status;
        return storage.isGranted;
      }
    }
    return true;
  }

  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final sdkVersion =
          int.parse(Platform.operatingSystemVersion.split('.').first);
      if (sdkVersion >= 33) {
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }

  static Future<bool> shouldShowPermissionRationale() async {
    if (Platform.isAndroid) {
      final sdkVersion =
          int.parse(Platform.operatingSystemVersion.split('.').first);
      if (sdkVersion >= 33) {
        return await Permission.photos.shouldShowRequestRationale;
      } else {
        return await Permission.storage.shouldShowRequestRationale;
      }
    }
    return false;
  }
}
