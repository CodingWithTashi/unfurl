import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unfurl/data/models/tag.dart';

class LatestTagCard extends StatelessWidget {
  final Tag? latestTag;
  final VoidCallback onEdit;
  final VoidCallback? onViewAll;
  final VoidCallback? onAdd;

  const LatestTagCard({
    Key? key,
    required this.latestTag,
    required this.onEdit,
    this.onViewAll,
    this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Trim title and description if they are too long
    final trimmedTitle = (latestTag?.tagName ?? 'Default Title').length > 50
        ? '${(latestTag?.tagName ?? 'Default Title').substring(0, 47)}...'
        : (latestTag?.tagName ?? 'Default Title');

    final trimmedDescription = (latestTag?.tagDescription ??
                    'Default Description')
                .length >
            100
        ? '${(latestTag?.tagDescription ?? 'Default Description').substring(0, 97)}...'
        : (latestTag?.tagDescription ?? 'Default Description');

    return Card(
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
                  'Latest Tag',
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
                child: latestTag != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trimmedTitle!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  trimmedDescription,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(latestTag!.updatedDate
                                        .isAfter(latestTag!.createdDate)
                                    ? 'Updated on ${DateFormat('dd/MM hh:mm a').format(latestTag!.updatedDate)}'
                                    : 'Created on ${DateFormat('dd/MM hh:mm a').format(latestTag!.createdDate)}'),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                          IconButton(
                              onPressed: onEdit,
                              icon: Icon(Icons.arrow_forward_ios))
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                            child: Text('No Tag Added,tray adding some!')),
                      ),
              ),
              Divider(
                height: 0.4,
              ),
              Center(
                child: TextButton(
                  onPressed: latestTag != null ? onViewAll : onAdd,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    latestTag != null ? 'View All' : 'Add New',
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
