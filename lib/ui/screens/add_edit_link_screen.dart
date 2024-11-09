import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unfurl/data/models/link.dart';

import '../../data/models/qr_code_generator.dart';
import '../../data/models/tag.dart';
import '../../states/link_provider.dart';

class AddEditLinkScreen extends ConsumerStatefulWidget {
  final UnfurlLink? link;
  const AddEditLinkScreen({super.key, this.link});

  @override
  ConsumerState createState() => _AddEditLinkScreenState();
}

class _AddEditLinkScreenState extends ConsumerState<AddEditLinkScreen> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController linkController;
  bool get isEditMode => widget.link != null;
  Tag? selectedTag;
  late double height;
  late double width;
  late final StreamController<String> _textStreamController;
  List<Tag> tagList = [];
  Tag defaultTag = Tag(
      id: -1,
      tagName: 'Select',
      tagDescription: 'Select Tag',
      createdDate: null,
      updatedDate: null,
      status: 'active');
  @override
  void initState() {
    titleController = TextEditingController(text: widget.link?.title ?? '');
    descriptionController =
        TextEditingController(text: widget.link?.description ?? '');
    linkController = TextEditingController(text: widget.link?.link ?? '');
    // set default tag value
    if (widget.link != null && widget.link!.tag != null) {
      selectedTag = widget.link!.tag;
    } else {
      selectedTag = defaultTag;
    }
    _textStreamController = StreamController<String>.broadcast();
    linkController.addListener(() {
      _textStreamController.sink.add(linkController.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    _textStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(!isEditMode ? 'Add Link' : 'Edit Link'),
        actions: [
          if (isEditMode) ...[
            IconButton(
              icon: const Icon(
                FluentIcons.share_24_regular,
              ),
              onPressed: () => QRCodeGenerator.showBottomSheet(
                  ctx: context, data: widget.link!),
            ),
            IconButton(
              icon:
                  const Icon(FluentIcons.delete_24_regular, color: Colors.red),
              onPressed: _handleDelete,
            ),
          ]
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Link Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: titleController,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Eg. Purchase Order',
                        hintStyle:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withOpacity(0.6),
                                ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Link Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Eg. Purchase Order for the month of June',
                        hintStyle:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withOpacity(0.6),
                                ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Links',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.url,
                      controller: linkController,
                      decoration: InputDecoration(
                        hintText: 'Eg. https://amazon.com',
                        hintStyle:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withOpacity(0.6),
                                ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        // Add suffix icon for copy functionality
                        suffixIcon: StreamBuilder<String>(
                            stream: _textStreamController.stream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  (snapshot.hasData &&
                                      snapshot.data!.isEmpty)) {
                                return const SizedBox.shrink();
                              }
                              return IconButton(
                                icon: const Icon(Icons.content_copy),
                                onPressed: () async {
                                  if (linkController.text.isNotEmpty) {
                                    await Clipboard.setData(
                                      ClipboardData(text: linkController.text),
                                    );
                                    // Show a snackbar to confirm copy
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Link copied to clipboard'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                tooltip: 'Copy link',
                              );
                            }),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tag',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: FutureBuilder<List<Tag>>(
                          future:
                              ref.read(databaseServiceProvider).getAllTags(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            // Clear and rebuild the list
                            tagList = [defaultTag];
                            if (snapshot.hasData) {
                              tagList.addAll(snapshot.data!);
                            }

                            // Ensure selectedTag is in the list
                            if (!tagList.contains(selectedTag)) {
                              selectedTag = defaultTag;
                            }

                            return DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton<Tag>(
                                  value: selectedTag,
                                  isExpanded: true,
                                  borderRadius: BorderRadius.circular(8),
                                  items: tagList.map((Tag value) {
                                    return DropdownMenuItem<Tag>(
                                      value: value,
                                      child: Text(
                                        value.tagName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (Tag? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedTag = newValue;
                                      });
                                    }
                                  },
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.primary)),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isEditMode ? 'Update' : 'Submit',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    // handle fields validation name,description and links
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        linkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all the fields'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    if (tagList.isEmpty || tagList.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a tag first'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    if (selectedTag?.id == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a tag'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    if (!isValidUrl(linkController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid URL'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    final now = DateTime.now();
    final newLink = UnfurlLink(
      id: widget.link?.id,
      title: titleController.text,
      description: descriptionController.text,
      link: linkController.text,
      createdDate: widget.link?.createdDate ?? now,
      updatedDate: now,
      status: 'active',
      tagId: selectedTag?.id,
      tag: selectedTag,
    );

    if (widget.link == null) {
      ref.read(linksProvider.notifier).addLink(newLink);
    } else {
      ref.read(linksProvider.notifier).updateLink(newLink);
    }

    Navigator.pop(context);
  }

  Future<void> _handleDelete() async {
    final shouldDelete = await _showDeleteConfirmation();
    if (shouldDelete && mounted && widget.link != null) {
      await ref.read(linksProvider.notifier).deleteLink(widget.link!.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: const Text('Are you sure you want to delete this link?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  bool isValidUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      return uri.isAbsolute && (uri.hasScheme && uri.hasAuthority);
    } catch (e) {
      return false;
    }
  }
}
