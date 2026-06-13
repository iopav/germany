import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/emus/app_enums.dart';
import 'package:germany/features/auth/data/models/user_model.dart';
import 'package:germany/features/auth/presentation/auth_provider.dart';
import 'package:germany/features/settings/presentation/settings_provider.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final Color primary = const Color(0xFF004AC6);
  final Color secondary = const Color(0xFF712AE2);
  final Color background = const Color(0xFFFAF8FF);
  final Color surface = const Color(0xFFFAF8FF);
  final Color onSurface = const Color(0xFF131B2E);
  final Color onSurfaceVariant = const Color(0xFF434655);
  final Color outline = const Color(0xFF737686);
  final Color surfaceContainer = const Color(0xFFEAEDFF);
  final Color error = const Color(0xFFBA1A1A);

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
      color: background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 100,
        ),
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
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: surfaceContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: primary.withValues(alpha: 0.2),
                  width: 4,
                ),
              ),
              child: CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: background, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          displayEmail,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user == null
              ? ''
              : 'Member since ${_formatMonthYear(user.createdAt)}',
          style: TextStyle(
            fontSize: 14,
            color: onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLearningGoalsCard(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: primary),
              const SizedBox(width: 8),
              const Text(
                'Learning Goals',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
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
                style: TextStyle(fontSize: 14, color: onSurfaceVariant),
              ),
              Text(
                levels[currentLevel.toInt()],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: surfaceContainer,
              inactiveTrackColor: surfaceContainer,
              thumbColor: primary,
              overlayColor: primary.withValues(alpha: 0.2),
              trackHeight: 8,
            ),
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
                style: TextStyle(fontSize: 14, color: onSurfaceVariant),
              ),
              Text(
                levels[targetLevel.toInt()],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFEADDFF),
              inactiveTrackColor: const Color(0xFFEADDFF),
              thumbColor: secondary,
              overlayColor: secondary.withValues(alpha: 0.2),
              trackHeight: 8,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: levels
            .map(
              (lvl) => Text(
                lvl,
                style: TextStyle(
                  fontSize: 12,
                  color: outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildNativeLanguageCard(AsyncValue<UserModel> settingsState) {
    final user = settingsState.asData?.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.translate, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Native Language',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  user == null ? 'Loading...' : user.l1Language.label,
                  style: TextStyle(fontSize: 13, color: onSurfaceVariant),
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
          backgroundColor: error,
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
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'ACCOUNT SETTINGS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: outline,
            ),
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
      borderRadius: BorderRadius.circular(12),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: outline),
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
          style: OutlinedButton.styleFrom(
            foregroundColor: error,
            side: BorderSide(color: error, width: 2),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout),
              SizedBox(width: 8),
              Text(
                'Sign Out',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Version 2.4.0 (Build 892)',
          style: TextStyle(
            fontSize: 12,
            color: outline.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
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
