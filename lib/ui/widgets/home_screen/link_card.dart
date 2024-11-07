import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../data/models/link.dart';

class LatestLinkCard extends StatelessWidget {
  final UnfurlLink? latestLink;
  final VoidCallback onEdit;
  final VoidCallback? onViewAll;
  final VoidCallback? onAdd;

  const LatestLinkCard({
    Key? key,
    required this.latestLink,
    required this.onEdit,
    this.onViewAll,
    this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Trim title and description if they are too long
    final trimmedTitle = (latestLink?.title ?? 'Default Title').length > 20
        ? '${(latestLink?.title ?? 'Default Title').substring(0, 10)}...'
        : (latestLink?.title ?? 'Default Title');

    final trimmedLink = (latestLink?.link ?? 'Default Description').length > 20
        ? '${(latestLink?.link ?? 'Default Description').substring(0, 15)}...'
        : (latestLink?.link ?? 'Default Description');

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'Latest Link',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: latestLink != null
                    ? InkResponse(
                        onTap: onEdit,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trimmedTitle!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    trimmedLink!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(latestLink!.updatedDate
                                          .isAfter(latestLink!.createdDate)
                                      ? 'Updated on ${DateFormat('dd/MM hh:mm a').format(latestLink!.updatedDate)}'
                                      : 'Created on ${DateFormat('dd/MM hh:mm a').format(latestLink!.createdDate)}'),
                                  const SizedBox(height: 12),
                                  Chip(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      elevation: 0,
                                      labelPadding:
                                          EdgeInsets.fromLTRB(0, -3, 0, -3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 0),
                                      label: Text(latestLink!.tag?.tagName ??
                                          'No Tag')),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                            child: Text('No Link Added,tray adding some!')),
                      ),
              ),
              Divider(
                height: 0.4,
              ),
              Center(
                child: TextButton(
                  onPressed: latestLink != null ? onViewAll : onAdd,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    latestLink != null ? 'View All' : 'Add New',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
