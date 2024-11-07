import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unfurl/services/link_database_service.dart';

import '../data/models/tag.dart';
import 'link_provider.dart';

final tagDatabaseServiceProvider = Provider((ref) => DatabaseService());

final tagsProvider = StateNotifierProvider<TagsNotifier, List<Tag>>((ref) {
  final databaseService = ref.watch(tagDatabaseServiceProvider);
  return TagsNotifier(databaseService, ref);
});

class TagsNotifier extends StateNotifier<List<Tag>> {
  final DatabaseService _databaseService;
  final Ref _ref;
  TagsNotifier(this._databaseService, this._ref) : super([]) {
    loadTags();
  }

  Future<void> loadTags() async {
    final tags = await _databaseService.getAllTags();
    state = tags;
  }

  Future<void> addTag(Tag tag) async {
    final newTag = await _databaseService.insertTag(tag);
    await loadTags();

    //state = [...state, newTag];
  }

  Future<void> updateTag(Tag tag) async {
    await _databaseService.updateTag(tag);
    await loadTags();
    _ref.read(linksProvider.notifier).loadLinks();
    // state = [
    //   for (final item in state)
    //     if (item.id == tag.id) tag else item
    // ];
  }

  Future<void> deleteTag(int id) async {
    await _databaseService.deleteTag(id);
    await loadTags();
    _ref.read(linksProvider.notifier).loadLinks();
    //state = state.where((tag) => tag.id != id).toList();
  }
}
