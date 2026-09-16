import 'package:shared_preferences/shared_preferences.dart';

/// Local-only favorited job-offer IDs, mirroring src/lib/app-mobile/favoris.ts.
/// This is NOT a Supabase table — job favorites live only on the device.
class LocalFavoritesStore {
  LocalFavoritesStore(this._prefs);

  static const _key = 'mywork.app.favoris-offres';
  static const _maxEntries = 200;

  final SharedPreferences _prefs;

  List<String> getAll() => _prefs.getStringList(_key) ?? const [];

  bool isFavorite(String offreId) => getAll().contains(offreId);

  Future<void> toggle(String offreId) async {
    final current = List<String>.from(getAll());
    if (current.contains(offreId)) {
      current.remove(offreId);
    } else {
      current.insert(0, offreId);
      if (current.length > _maxEntries) {
        current.removeRange(_maxEntries, current.length);
      }
    }
    await _prefs.setStringList(_key, current);
  }
}
