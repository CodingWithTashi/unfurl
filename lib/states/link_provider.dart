import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unfurl/data/models/link.dart';

import '../services/link_database_service.dart';

final databaseServiceProvider = Provider((ref) => DatabaseService());

final linksProvider =
    StateNotifierProvider<LinksNotifier, List<UnfurlLink>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return LinksNotifier(databaseService);
});

class LinksNotifier extends StateNotifier<List<UnfurlLink>> {
  final DatabaseService _databaseService;

  LinksNotifier(this._databaseService) : super([]) {
    loadLinks();
  }

  Future<void> loadLinks() async {
    print("Loading links");
    final links = await _databaseService.getAllLinksWithTags();
    state = links;
  }

  Future<void> addLink(UnfurlLink link) async {
    final newLink = await _databaseService.insertLink(link);
    await loadLinks();
    // state = [...state, newLink];
  }

  Future<void> updateLink(UnfurlLink link) async {
    await _databaseService.updateLink(link);
    await loadLinks();
    // state = [
    //   for (final item in state)
    //     if (item.id == link.id) link else item
    // ];
  }

  Future<void> deleteLink(int id) async {
    await _databaseService.deleteLink(id);
    await loadLinks();
    // state = state.where((link) => link.id != id).toList();
  }
}
