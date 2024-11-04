import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unfurl/data/models/link.dart';

import '../../states/link_provider.dart';

class AddEditLinkScreen extends ConsumerWidget {
  final UnfurlLink? link;
  const AddEditLinkScreen({super.key, this.link});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController(text: link?.title);
    final descriptionController =
        TextEditingController(text: link?.description);
    final linkController = TextEditingController(text: link?.link);
    String status = link?.status ?? 'active';

    return Scaffold(
      appBar: AppBar(
        title: Text(link == null ? 'Add Link' : 'Edit Link'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(labelText: 'Link'),
            ),
            DropdownButton<String>(
              value: status,
              items: ['active', 'archive'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  status = newValue;
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                final now = DateTime.now();
                final newLink = UnfurlLink(
                  id: link?.id,
                  title: titleController.text,
                  description: descriptionController.text,
                  link: linkController.text,
                  createdDate: link?.createdDate ?? now,
                  updatedDate: now,
                  status: status,
                );

                if (link == null) {
                  ref.read(linksProvider.notifier).addLink(newLink);
                } else {
                  ref.read(linksProvider.notifier).updateLink(newLink);
                }

                Navigator.pop(context);
              },
              child: Text(link == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
