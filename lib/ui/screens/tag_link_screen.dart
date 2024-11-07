import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unfurl/data/models/link.dart';
import 'package:unfurl/states/link_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TagLinkScreen extends ConsumerWidget {
  final int tagId;
  const TagLinkScreen({super.key, required this.tagId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag Links'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<List<UnfurlLink>>(
          future: ref.read(databaseServiceProvider).getLinksForTag(tagId),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final links = snapshot.data ?? [];

            if (links.isEmpty) {
              return const Center(child: Text('No links found'));
            }

            return ListView.builder(
              itemCount: links.length,
              itemBuilder: (context, index) {
                final link = links[index];
                return ListTile(
                  title: Text(link.title),
                  subtitle: Text(link.link),
                  onTap: () async {
                    if (await canLaunchUrl(Uri.parse(link.link))) {
                      launchUrl(Uri.parse(link.link));
                    }
                  },
                );
              },
            );
          }),
    );
  }
}
