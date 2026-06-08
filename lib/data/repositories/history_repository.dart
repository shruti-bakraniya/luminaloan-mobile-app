import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/saved_calculation.dart';

abstract class HistoryRepository {
  Future<List<SavedCalculation>> getAll();
  Future<void> save(SavedCalculation calc);
  Future<void> delete(String id);
}

class SharedPrefsHistoryRepository implements HistoryRepository {
  static const _key = 'lumina_history';
  final SharedPreferences _prefs;

  SharedPrefsHistoryRepository(this._prefs);

  @override
  Future<List<SavedCalculation>> getAll() async {
    final raw = _prefs.getStringList(_key) ?? [];
    final results = <SavedCalculation>[];
    for (final s in raw) {
      try {
        results.add(SavedCalculation.fromJsonString(s));
      } catch (_) {}
    }
    return results.reversed.toList();
  }

  @override
  Future<void> save(SavedCalculation calc) async {
    final raw = _prefs.getStringList(_key) ?? [];
    raw.add(calc.toJsonString());
    await _prefs.setStringList(_key, raw);
  }

  @override
  Future<void> delete(String id) async {
    final raw = _prefs.getStringList(_key) ?? [];
    raw.removeWhere((s) {
      try {
        return SavedCalculation.fromJsonString(s).id == id;
      } catch (_) {
        return false;
      }
    });
    await _prefs.setStringList(_key, raw);
  }
}
