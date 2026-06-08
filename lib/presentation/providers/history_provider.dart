import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/history_repository.dart';
import '../../domain/entities/saved_calculation.dart';

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final historyRepositoryProvider = Provider<HistoryRepository?>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.whenOrNull(
    data: (p) => SharedPrefsHistoryRepository(p),
  );
});

final historyProvider = StateNotifierProvider<HistoryNotifier, List<SavedCalculation>>((ref) {
  return HistoryNotifier(ref.watch(historyRepositoryProvider));
});

class HistoryNotifier extends StateNotifier<List<SavedCalculation>> {
  final HistoryRepository? _repo;

  HistoryNotifier(this._repo) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final items = await _repo?.getAll() ?? [];
    state = items;
  }

  Future<void> save(SavedCalculation calc) async {
    await _repo?.save(calc);
    state = [calc, ...state];
  }

  Future<void> delete(String id) async {
    await _repo?.delete(id);
    state = state.where((c) => c.id != id).toList();
  }
}
