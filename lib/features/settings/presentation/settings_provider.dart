import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/emus/app_enums.dart';
import 'package:germany/features/auth/data/models/user_model.dart';
import 'package:germany/features/settings/data/models/settings_model.dart';
import 'package:germany/features/settings/data/services/settings_service.dart';

class SettingsNotifier extends AsyncNotifier<UserModel> {
  @override
  Future<UserModel> build() {
    return ref.read(settingsServiceProvider).fetchUserInfo();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<UserModel>();
    state = await AsyncValue.guard(
      () => ref.read(settingsServiceProvider).fetchUserInfo(),
    );
  }

  Future<void> updateLanguageInfo({
    required L1Language l1Language,
    required CEFRLevel targetLevel,
  }) async {
    final previous = state.asData?.value;
    if (previous != null) {
      state = AsyncData(
        previous.copyWith(l1Language: l1Language, targetLevel: targetLevel),
      );
    }

    final result = await AsyncValue.guard(
      () => ref
          .read(settingsServiceProvider)
          .updateUserInfo(
            UpdateUserRequestModel(
              l1Language: l1Language,
              targetLevel: targetLevel,
            ),
          ),
    );

    state = result.when(
      data: AsyncData.new,
      error: (error, stackTrace) {
        if (previous != null) {
          return AsyncData(previous);
        }
        return AsyncError<UserModel>(error, stackTrace);
      },
      loading: () => state,
    );
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, UserModel>(
  SettingsNotifier.new,
);
