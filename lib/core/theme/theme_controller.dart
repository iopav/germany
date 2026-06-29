import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_palette.dart';

const _palettePreferenceKey = 'app_palette';

final appPaletteControllerProvider =
    AsyncNotifierProvider<AppPaletteController, AppPaletteKey>(
      AppPaletteController.new,
    );

final appPaletteProvider = Provider<AppPalette>((ref) {
  final key = ref
      .watch(appPaletteControllerProvider)
      .maybeWhen(data: (value) => value, orElse: () => AppPaletteKey.warm);
  return AppPalettes.byKey(key);
});

class AppPaletteController extends AsyncNotifier<AppPaletteKey> {
  @override
  Future<AppPaletteKey> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPaletteKey.fromName(prefs.getString(_palettePreferenceKey));
  }

  Future<void> setPalette(AppPaletteKey key) async {
    state = AsyncData(key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_palettePreferenceKey, key.name);
  }
}
