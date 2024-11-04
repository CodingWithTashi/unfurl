import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/tag.dart';
import '../services/tag_database_service.dart';

final tagDatabaseServiceProvider = Provider((ref) => TagDatabaseService());

final tagsProvider = StateNotifierProvider<TagsNotifier, List<Tag>>((ref) {
  final databaseService = ref.watch(tagDatabaseServiceProvider);
  return TagsNotifier(databaseService);
});

class TagsNotifier extends StateNotifier<List<Tag>> {
  final TagDatabaseService _databaseService;

  TagsNotifier(this._databaseService) : super([]) {
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
    // state = [
    //   for (final item in state)
    //     if (item.id == tag.id) tag else item
    // ];
  }

  Future<void> deleteTag(int id) async {
    await _databaseService.deleteTag(id);
    await loadTags();
    //state = state.where((tag) => tag.id != id).toList();
  }
}
