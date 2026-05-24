import 'package:shared_preferences/shared_preferences.dart';

/// Persists recent search queries for quick recall on the search screen.
class RecentSearchStore {
  RecentSearchStore({SharedPreferences? preferences})
      : _preferences = preferences;

  static const _key = 'search_recent_queries';
  static const _maxEntries = 8;

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<List<String>> load() async {
    final prefs = await _prefs;
    return prefs.getStringList(_key) ?? const [];
  }

  Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final prefs = await _prefs;
    final current = List<String>.from(prefs.getStringList(_key) ?? const []);
    current.removeWhere((entry) => entry.toLowerCase() == trimmed.toLowerCase());
    current.insert(0, trimmed);
    if (current.length > _maxEntries) {
      current.removeRange(_maxEntries, current.length);
    }
    await prefs.setStringList(_key, current);
  }

  Future<void> remove(String query) async {
    final prefs = await _prefs;
    final current = List<String>.from(prefs.getStringList(_key) ?? const []);
    current.remove(query);
    await prefs.setStringList(_key, current);
  }
}
