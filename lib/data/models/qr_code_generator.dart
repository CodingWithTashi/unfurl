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
        id: 'null',
        title: 'null',
        description: 'null',
        link: 'null',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
        status: 'null',
        tagId: obj.id,
        tagName: obj.tagName, // Null for Link type
        tagDescription: obj.tagDescription, // Null for Link type
        tagCreatedDate: obj.createdDate, // Null for Link type
        tagUpdatedDate: obj.updatedDate, // Null for Link type
        tagStatus: obj.status, // Null for Link type
      );
    } else if (obj is UnfurlLink) {
      return QRCodeData(
        packageName: 'com.greg.unfurl',
        type: 'Link',
        id: obj.id?.toString() ?? '',
        title: obj.title,
        description: obj.description,
        link: obj.link,
        createdDate: obj.createdDate,
        updatedDate: obj.updatedDate,
        status: obj.status,
        tagId: obj.tagId ?? -1,
        tagName: obj.tag?.tagName ?? 'null', // Null for Link type
        tagDescription: obj.tag?.tagDescription ?? 'null', // Null for Link type
        tagCreatedDate:
            obj.tag?.createdDate ?? DateTime.now(), // Null for Link type
        tagUpdatedDate:
            obj.tag?.updatedDate ?? DateTime.now(), // Null for Link type
        tagStatus: obj.tag?.status ?? 'null', // Null for Link type
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
      data.title,
      data.description,
      data.link,
      data.createdDate,
      data.updatedDate,
      data.status,
      data.tagId.toString(),
      data.tagName,
      data.tagDescription,
      data.tagCreatedDate,
      data.tagUpdatedDate,
      data.tagStatus,
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
                  size: MediaQuery.of(context).size.width * 0.4,
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
