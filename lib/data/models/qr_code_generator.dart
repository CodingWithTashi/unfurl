import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:unfurl/data/models/qr_code_data.dart';
import 'package:unfurl/data/models/tag.dart';

import 'link.dart';

class QRCodeGenerator {
  static QRCodeData convertToQRCodeData(dynamic obj) {
    if (obj is Tag) {
      return QRCodeData(
        packageName: 'com.greg.unfurl',
        type: 'Tag',
        id: obj.id?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: '', // Null for Tag type
        description: '', // Null for Tag type
        link: '', // Null for Tag type
        tagName: obj.tagName,
        tagDescription: obj.tagDescription,
        createdDate: obj.createdDate,
        updatedDate: obj.updatedDate,
        status: obj.status,
      );
    } else if (obj is UnfurlLink) {
      return QRCodeData(
        packageName: 'com.greg.unfurl',
        type: 'Link',
        id: obj.id?.toString() ?? '',
        title: obj.title,
        description: obj.description,
        link: obj.link,
        tagName: '', // Null for Link type
        tagDescription: '', // Null for Link type
        createdDate: obj.createdDate,
        updatedDate: obj.updatedDate,
        status: obj.status,
      );
    } else {
      throw ArgumentError('Unsupported object type');
    }
  }

  static String generateQRCodeString(QRCodeData data) {
    final qrCodeElements = [
      data.packageName,
      data.type,
      data.id,
      if (data.type == 'Link') data.title else '',
      if (data.type == 'Link') data.description else '',
      if (data.type == 'Link') data.link else '',
      data.tagName,
      data.tagDescription,
      data.createdDate.toIso8601String(),
      data.updatedDate.toIso8601String(),
      data.status,
    ];
    return qrCodeElements.join('||');
  }

  static String generateQRCode(dynamic obj) {
    final qrCodeData = convertToQRCodeData(obj);
    return generateQRCodeString(qrCodeData);
  }

  static String generateTagQRCode(Tag tag) {
    return generateQRCode(tag);
  }

  static showBottomSheet({required dynamic data, required BuildContext ctx}) {
    showModalBottomSheet(
      context: ctx,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(24),
              topRight: const Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data is Tag ? 'Share Tag' : 'Share Link',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),
              Container(
                color: Theme.of(context).colorScheme.onSecondary,
                child: QrImageView(
                  size: MediaQuery.of(context).size.width * 0.3,
                  data: generateQRCode(data),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: const Text('Close'),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
