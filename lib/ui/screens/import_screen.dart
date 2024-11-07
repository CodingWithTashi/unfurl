import 'package:flutter/material.dart';

import '../../data/models/link.dart';
import '../../data/models/tag.dart';

class ImportScreen extends StatefulWidget {
  final Map<Tag, List<UnfurlLink>> importData;
  final Function(Map<Tag, List<UnfurlLink>>) onImport;

  const ImportScreen({
    Key? key,
    required this.importData,
    required this.onImport,
  }) : super(key: key);

  @override
  _ImportScreenState createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  Map<Tag, List<UnfurlLink>> selectedData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Filter Tags'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.importData.length,
              itemBuilder: (context, index) {
                final tag = widget.importData.keys.elementAt(index);
                final links = widget.importData[tag]!;
                final isSelected = selectedData.containsKey(tag);

                return ExpansionTile(
                  title: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          if (value!) {
                            selectedData[tag] = links;
                          } else {
                            selectedData.remove(tag);
                          }
                          setState(() {});
                        },
                      ),
                      Expanded(
                          child: Text(tag
                              .tagName)), // Title with expansion to take remaining space
                    ],
                  ),
                  trailing: Icon(
                      Icons.expand_more), // Explicit dropdown icon at the end
                  children: links.asMap().entries.map((entry) {
                    int index = entry.key;
                    var link = entry.value;
                    return ListTile(
                      leading: Checkbox(
                        value: isSelected && selectedData[tag]!.contains(link),
                        onChanged: (value) {
                          if (value!) {
                            selectedData[tag]!.add(link);
                          } else {
                            selectedData[tag]!.remove(link);
                          }
                          setState(() {});
                        },
                      ),
                      title: Text(
                          '${index + 1}. ${link.link}'), // Adding numbering here
                    );
                  }).toList(),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onImport(selectedData);
              Navigator.pop(context);
            },
            child: Text('Import'),
          ),
        ],
      ),
    );
  }
}
