import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../data/models/link.dart';

class LatestLinkCard extends StatelessWidget {
  final UnfurlLink latestLink;
  final VoidCallback onEdit;
  final VoidCallback onViewAll;

  const LatestLinkCard({
    Key? key,
    required this.latestLink,
    required this.onEdit,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Trim title and description if they are too long
    final trimmedTitle = latestLink.title.length > 50
        ? '${latestLink.title.substring(0, 47)}...'
        : latestLink.title;
    final trimmedDescription = latestLink.description.length > 100
        ? '${latestLink.description.substring(0, 97)}...'
        : latestLink.description;

    return Card(
      elevation: 0,
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
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trimmedTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          trimmedDescription,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(latestLink.updatedDate
                                .isAfter(latestLink.createdDate)
                            ? 'Updated on ${DateFormat('dd/MM hh:mm a').format(latestLink.updatedDate)}'
                            : 'Created on ${latestLink.createdDate}'),
                        const SizedBox(height: 12),
                      ],
                    ),
                    IconButton(
                        onPressed: onEdit, icon: Icon(Icons.arrow_forward_ios))
                  ],
                ),
              ),
              Divider(
                height: 0.4,
              ),
              Center(
                child: TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
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