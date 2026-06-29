import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/emus/app_enums.dart';
import 'package:germany/core/theme/app_palette.dart';
import 'package:germany/core/theme/theme_controller.dart';
import 'package:germany/features/auth/data/models/user_model.dart';
import 'package:germany/features/auth/presentation/auth_provider.dart';
import 'package:germany/features/settings/presentation/settings_provider.dart';
import 'package:go_router/go_router.dart';

import 'settings_style.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final List<String> levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  double currentLevel = 2; // B1
  double targetLevel = 4; // C1, hydrated from /auth/me target_level.
  bool _hasHydratedTargetLevel = false;

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final user = settingsState.asData?.value;
    if (user != null && !_hasHydratedTargetLevel) {
      targetLevel = _levelIndex(user.targetLevel).toDouble();
      _hasHydratedTargetLevel = true;
    }

    return ColoredBox(
      color: SettingsStyle.backgroundColor(context),
      child: SingleChildScrollView(
        padding: SettingsStyle.pagePadding,
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 24),
            _buildLearningGoalsCard(user),
            const SizedBox(height: 32),
            _buildNativeLanguageCard(settingsState),
            const SizedBox(height: 32),
            _buildThemeCard(),
            const SizedBox(height: 32),
            _buildAccountSettings(),
            const SizedBox(height: 24),
            _buildSignOutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? user) {
    final email = user?.email.trim() ?? '';
    final displayEmail = email.isEmpty ? 'Loading...' : email;
    final avatarUrl = Uri.https('ui-avatars.com', '/api/', {
      'name': email.isEmpty ? 'User' : email,
      'background': '004ac6',
      'color': 'fff',
    }).toString();

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              padding: SettingsStyle.avatarPadding,
              decoration: SettingsStyle.avatarDecorationFor(context),
              child: CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: SettingsStyle.proBadgePadding,
                decoration: SettingsStyle.proBadgeDecorationFor(context),
                child: Text(
                  'PRO',
                  style: SettingsStyle.proBadgeTextStyleFor(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(displayEmail, style: SettingsStyle.emailTextStyleFor(context)),
        const SizedBox(height: 4),
        Text(
          user == null
              ? ''
              : 'Member since ${_formatMonthYear(user.createdAt)}',
          style: SettingsStyle.memberSinceTextStyleFor(context),
        ),
      ],
    );
  }

  Widget _buildLearningGoalsCard(UserModel? user) {
    return Container(
      padding: SettingsStyle.largeCardPadding,
      decoration: SettingsStyle.cardDecorationFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: SettingsStyle.colors(context).primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Learning Goals',
                style: SettingsStyle.cardTitleTextStyleFor(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Current Level',
                style: SettingsStyle.fieldLabelTextStyleFor(context),
              ),
              Text(
                levels[currentLevel.toInt()],
                style: SettingsStyle.primaryLevelTextStyleFor(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SettingsStyle.currentSliderTheme(context),
            child: Slider(
              value: currentLevel,
              min: 0,
              max: 5,
              divisions: 5,
              onChanged: (val) => setState(() => currentLevel = val),
            ),
          ),
          _buildLevelLabels(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Target Level',
                style: SettingsStyle.fieldLabelTextStyleFor(context),
              ),
              Text(
                levels[targetLevel.toInt()],
                style: SettingsStyle.secondaryLevelTextStyleFor(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SettingsStyle.targetSliderTheme(context),
            child: Slider(
              value: targetLevel,
              min: 0,
              max: 5,
              divisions: 5,
              onChanged: (val) => setState(() => targetLevel = val),
              onChangeEnd: user == null
                  ? null
                  : (val) => ref
                        .read(settingsProvider.notifier)
                        .updateLanguageInfo(
                          l1Language: user.l1Language,
                          targetLevel: CEFRLevel.values[val.round()],
                        ),
            ),
          ),
          _buildLevelLabels(),
        ],
      ),
    );
  }

  Widget _buildLevelLabels() {
    return Padding(
      padding: SettingsStyle.levelLabelPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: levels
            .map(
              (lvl) => Text(
                lvl,
                style: SettingsStyle.levelTickTextStyleFor(context),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildNativeLanguageCard(AsyncValue<UserModel> settingsState) {
    final user = settingsState.asData?.value;

    return Container(
      padding: SettingsStyle.cardPadding,
      decoration: SettingsStyle.cardDecorationFor(context),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: SettingsStyle.iconCircleDecorationFor(context),
            child: Icon(
              Icons.translate,
              color: SettingsStyle.colors(context).primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Native Language',
                  style: SettingsStyle.tileTitleTextStyleFor(context),
                ),
                const SizedBox(height: 2),
                Text(
                  user == null ? 'Loading...' : user.l1Language.label,
                  style: SettingsStyle.tileSubtitleTextStyleFor(context),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: user == null || settingsState.isLoading
                ? null
                : () => _showNativeLanguageDialog(user.l1Language),
            child: settingsState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Future<void> _showNativeLanguageDialog(L1Language currentLanguage) async {
    final selectedLanguage = await showDialog<L1Language>(
      context: context,
      builder: (context) {
        var draftLanguage = currentLanguage;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Native Language'),
              content: DropdownButtonFormField<L1Language>(
                initialValue: draftLanguage,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: L1Language.values
                    .map(
                      (language) => DropdownMenuItem(
                        value: language,
                        child: Text(language.label),
                      ),
                    )
                    .toList(),
                onChanged: (language) {
                  if (language == null) {
                    return;
                  }
                  setDialogState(() => draftLanguage = language);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(draftLanguage),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedLanguage == null || selectedLanguage == currentLanguage) {
      return;
    }

    final user = ref.read(settingsProvider).asData?.value;
    if (user == null) {
      return;
    }

    await ref
        .read(settingsProvider.notifier)
        .updateLanguageInfo(
          l1Language: selectedLanguage,
          targetLevel: user.targetLevel,
        );

    if (!mounted) {
      return;
    }

    final latestState = ref.read(settingsProvider);
    if (latestState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            latestState.error.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: SettingsStyle.colors(context).error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Native language updated.')));
  }

  Widget _buildThemeCard() {
    final paletteKey = ref
        .watch(appPaletteControllerProvider)
        .maybeWhen(data: (value) => value, orElse: () => AppPaletteKey.warm);
    final palette = SettingsStyle.colors(context);

    return Container(
      padding: SettingsStyle.cardPadding,
      decoration: SettingsStyle.cardDecorationFor(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: SettingsStyle.iconCircleDecorationFor(context),
            child: Icon(Icons.palette_outlined, color: palette.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Theme',
                  style: SettingsStyle.tileTitleTextStyleFor(context),
                ),
                const SizedBox(height: 2),
                Text(
                  paletteKey == AppPaletteKey.warm
                      ? 'Warm mosaic'
                      : 'Cool glass',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SettingsStyle.tileSubtitleTextStyleFor(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 112,
            child: SegmentedButton<AppPaletteKey>(
              showSelectedIcon: false,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
                  if (states.contains(WidgetState.selected)) {
                    return palette.primary;
                  }
                  return palette.surfaceContainerLow;
                }),
                foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
                  if (states.contains(WidgetState.selected)) {
                    return palette.onPrimary;
                  }
                  return palette.onSurfaceVariant;
                }),
                side: WidgetStateProperty.all(
                  BorderSide(color: palette.outlineVariant),
                ),
              ),
              segments: const [
                ButtonSegment(
                  value: AppPaletteKey.cool,
                  icon: Icon(Icons.ac_unit),
                ),
                ButtonSegment(
                  value: AppPaletteKey.warm,
                  icon: Icon(Icons.local_fire_department_outlined),
                ),
              ],
              selected: {paletteKey},
              onSelectionChanged: (selection) {
                ref
                    .read(appPaletteControllerProvider.notifier)
                    .setPalette(selection.first);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: SettingsStyle.sectionLabelPadding,
          child: Text(
            'ACCOUNT SETTINGS',
            style: SettingsStyle.sectionLabelTextStyleFor(context),
          ),
        ),
        _buildSettingTile(Icons.security_outlined, 'Privacy & Security'),
        const SizedBox(height: 8),
        _buildSettingTile(Icons.notifications_active_outlined, 'Notifications'),
        const SizedBox(height: 8),
        _buildSettingTile(Icons.help_outline, 'Help & Support'),
      ],
    );
  }

  Widget _buildSettingTile(IconData icon, String title) {
    return InkWell(
      borderRadius: SettingsStyle.cardRadius,
      onTap: () {},
      child: Container(
        padding: SettingsStyle.cardPadding,
        decoration: SettingsStyle.cardDecorationFor(context),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: SettingsStyle.iconCircleDecorationFor(context),
              child: Icon(icon, color: SettingsStyle.colors(context).primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: SettingsStyle.tileTitleTextStyleFor(context),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: SettingsStyle.colors(context).outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutSection() {
    return Column(
      children: [
        OutlinedButton(
          onPressed: _handleSignOut,
          style: SettingsStyle.signOutButtonStyleFor(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout),
              const SizedBox(width: 8),
              Text(
                'Sign Out',
                style: SettingsStyle.signOutTextStyleFor(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Version 2.4.0 (Build 892)',
          style: SettingsStyle.versionTextStyleFor(context),
        ),
      ],
    );
  }

  Future<void> _handleSignOut() async {
    await ref.read(authProvider.notifier).logout();
    ref.invalidate(settingsProvider);

    if (!mounted) {
      return;
    }

    context.go('/login');
  }

  int _levelIndex(CEFRLevel level) {
    final index = CEFRLevel.values.indexOf(level);
    return index < 0 ? 0 : index.clamp(0, levels.length - 1);
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
