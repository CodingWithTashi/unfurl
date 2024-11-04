import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unfurl/data/models/link.dart';

import '../services/link_database_service.dart';

final databaseServiceProvider = Provider((ref) => DatabaseService());

final linksProvider =
    StateNotifierProvider<LinksNotifier, List<UnfurlLink>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return LinksNotifier(databaseService);
});

final latestLinkProvider = StreamProvider<UnfurlLink?>((ref) {
  final linkNotifier = ref.watch(linksProvider.notifier);
  return linkNotifier.watchLatestLink();
});

class LinksNotifier extends StateNotifier<List<UnfurlLink>> {
  final DatabaseService _databaseService;

  LinksNotifier(this._databaseService) : super([]) {
    loadLinks();
  }

  Future<void> loadLinks() async {
    final links = await _databaseService.getAllLinks();
    state = links;
  }

  Future<void> addLink(UnfurlLink link) async {
    final newLink = await _databaseService.insertLink(link);
    state = [...state, newLink];
  }

  Future<void> updateLink(UnfurlLink link) async {
    await _databaseService.updateLink(link);
    state = [
      for (final item in state)
        if (item.id == link.id) link else item
    ];
  }

  Future<void> deleteLink(int id) async {
    await _databaseService.deleteLink(id);
    state = state.where((link) => link.id != id).toList();
  }

  Stream<UnfurlLink?> watchLatestLink() {
    return _databaseService.watchLatestLink();
  }
}
