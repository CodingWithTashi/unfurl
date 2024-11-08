import 'package:flutter/material.dart';

import '../../data/models/link.dart';
import '../../data/models/tag.dart';

class FilterScreen extends StatefulWidget {
  final Map<Tag, List<UnfurlLink>> data;
  final Function(Map<Tag, List<UnfurlLink>>) onFiltered;
  final bool isImport;

  const FilterScreen({
    Key? key,
    required this.data,
    required this.onFiltered,
    this.isImport = true,
  }) : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
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
              itemCount: widget.data.length,
              itemBuilder: (context, index) {
                final tag = widget.data.keys.elementAt(index);
                final links = widget.data[tag]!;
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
                      // leading: Checkbox(
                      //   value: isSelected && selectedData[tag]!.contains(link),
                      //   onChanged: (value) {
                      //     if (value!) {
                      //       selectedData[tag]?.add(link);
                      //     } else {
                      //       selectedData[tag]?.remove(link);
                      //     }
                      //     setState(() {});
                      //   },
                      // ),
                      title: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text('${index + 1}. ${link.link}'),
                      ), // Adding numbering here
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: OutlinedButton(
              // width: double.infinity,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                widget.onFiltered(selectedData);
                Navigator.pop(context);
              },
              child: Text(widget.isImport ? 'Import' : 'Export'),
            ),
          ),
        ],
      ),
    );
  }
}
