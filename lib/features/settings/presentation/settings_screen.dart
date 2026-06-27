import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/emus/app_enums.dart';
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
      color: SettingsStyle.background,
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
              decoration: SettingsStyle.avatarDecoration,
              child: CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: SettingsStyle.proBadgePadding,
                decoration: SettingsStyle.proBadgeDecoration,
                child: const Text(
                  'PRO',
                  style: SettingsStyle.proBadgeTextStyle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(displayEmail, style: SettingsStyle.emailTextStyle),
        const SizedBox(height: 4),
        Text(
          user == null
              ? ''
              : 'Member since ${_formatMonthYear(user.createdAt)}',
          style: SettingsStyle.memberSinceTextStyle,
        ),
      ],
    );
  }

  Widget _buildLearningGoalsCard(UserModel? user) {
    return Container(
      padding: SettingsStyle.largeCardPadding,
      decoration: SettingsStyle.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: SettingsStyle.primary),
              const SizedBox(width: 8),
              const Text(
                'Learning Goals',
                style: SettingsStyle.cardTitleTextStyle,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Current Level', style: SettingsStyle.fieldLabelTextStyle),
              Text(
                levels[currentLevel.toInt()],
                style: SettingsStyle.primaryLevelTextStyle,
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
              Text('Target Level', style: SettingsStyle.fieldLabelTextStyle),
              Text(
                levels[targetLevel.toInt()],
                style: SettingsStyle.secondaryLevelTextStyle,
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
            .map((lvl) => Text(lvl, style: SettingsStyle.levelTickTextStyle))
            .toList(),
      ),
    );
  }

  Widget _buildNativeLanguageCard(AsyncValue<UserModel> settingsState) {
    final user = settingsState.asData?.value;

    return Container(
      padding: SettingsStyle.cardPadding,
      decoration: SettingsStyle.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: SettingsStyle.iconCircleDecoration,
            child: Icon(Icons.translate, color: SettingsStyle.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Native Language',
                  style: SettingsStyle.tileTitleTextStyle,
                ),
                const SizedBox(height: 2),
                Text(
                  user == null ? 'Loading...' : user.l1Language.label,
                  style: SettingsStyle.tileSubtitleTextStyle,
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
          backgroundColor: SettingsStyle.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Native language updated.')));
  }

  Widget _buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: SettingsStyle.sectionLabelPadding,
          child: Text(
            'ACCOUNT SETTINGS',
            style: SettingsStyle.sectionLabelTextStyle,
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
        decoration: SettingsStyle.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: SettingsStyle.iconCircleDecoration,
              child: Icon(icon, color: SettingsStyle.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: SettingsStyle.tileTitleTextStyle),
            ),
            Icon(Icons.chevron_right, color: SettingsStyle.outline),
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
          style: SettingsStyle.signOutButtonStyle,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout),
              SizedBox(width: 8),
              Text('Sign Out', style: SettingsStyle.signOutTextStyle),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Version 2.4.0 (Build 892)',
          style: SettingsStyle.versionTextStyle,
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
