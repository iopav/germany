import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:germany/core/utils/level_wheel_picker.dart';

import 'home_provider.dart';
import 'immersive_screen.dart';

/// Maps directly to the provided Tailwind theme configuration
class _AppColors {
  static const Color background = Color(0xFFFAF8FF);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color primary = Color(0xFF004AC6);
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color outlineVariant = Color(0xFFC3C6D7);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color surfaceContainerHighest = Color(0xFFDAE2FD);
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();

  bool _isMenuOpen = false;

  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _fillPrompt(String text) {
    setState(() {
      _promptController.text = text;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ref.read(homeProvider.notifier).pickImage(source);
    if (!mounted) return;

    setState(() => _isMenuOpen = false);
    final error = ref.read(homeProvider).errorMessage;
    if (error != null && error.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    if (pickedImage == null) {
      return;
    }

    await _startGeneration();
  }

  Future<void> _startGeneration() async {
    final validationError = await ref
        .read(homeProvider.notifier)
        .validateSelectedImage();
    if (validationError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    try {
      final scene = await ref.read(homeProvider.notifier).generateScene();
      if (!mounted) return;

      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ImmersiveScreen(scene: scene)));
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    //TODO ref listen
    return Scaffold(
      backgroundColor: _AppColors.background,
      extendBodyBehindAppBar: true,
      extendBody: true,

      // 1. Top AppBar (Frosted Glass)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AppBar(
              backgroundColor: _AppColors.surface.withOpacity(0.8),
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: _AppColors.outlineVariant.withOpacity(0.3),
                  height: 1,
                ),
              ),
              title: const Row(
                children: [
                  Icon(Icons.language, color: _AppColors.primary),
                  SizedBox(width: 12),
                  Text(
                    'Scenes',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _AppColors.primary,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.help_outline,
                    color: _AppColors.onSurfaceVariant,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),

      // 2. Main Content
      body: ListView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 80,
          left: 16,
          right: 16,
          bottom: 120, // space for bottom nav
        ),
        children: [
          // Header Texts
          const Text(
            'Create Scene',
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: _AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Capture the world or describe a moment to start your immersion journey.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: _AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // 3. Image Upload Area
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                color: _AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: _AppColors.outlineVariant.withOpacity(0.1),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder Image with blend mode
                  Opacity(
                    opacity: 0.6,
                    child: _buildImagePreview(homeState.selectedImage),
                  ),

                  // Gradient Overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            _AppColors.surfaceContainerHighest.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Center Add Button & Menu
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              setState(() => _isMenuOpen = !_isMenuOpen),
                          child: _buildGlassContainer(
                            radius: 24,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 32,
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 36,
                                  color: _AppColors.primary,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Add Scene Image',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Expandable Menu
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: _isMenuOpen
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: _buildGlassContainer(
                                    radius: 16,
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      children: [
                                        _buildMenuOption(
                                          Icons.photo_camera,
                                          'Camera',
                                          () => _pickImage(ImageSource.camera),
                                        ),
                                        Divider(
                                          height: 1,
                                          color: _AppColors.outlineVariant
                                              .withOpacity(0.3),
                                        ),
                                        _buildMenuOption(
                                          Icons.image,
                                          'Gallery',
                                          () => _pickImage(ImageSource.gallery),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 4. Generation Dialogue Panel
          _buildGlassContainer(
            radius: 28,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _promptController,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: _AppColors.onSurface,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Describe a scene...',
                            hintStyle: TextStyle(color: Colors.black38),
                            prefixIcon: Icon(
                              Icons.auto_awesome,
                              color: _AppColors.primary,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Level Picker Strip
                    // Container(
                    //   height: 48,
                    //   padding: const EdgeInsets.all(4),
                    //   decoration: BoxDecoration(
                    //     color: Colors.black.withOpacity(0.05),
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child:
                    LevelWheelPicker(
                      levels: const ['A1', 'A2', 'B1', 'B2', 'C1'],
                      initialLevel: 'A1',
                      onLevelChanged: (newLevel) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('change to $newLevel'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),

                    // ),
                    // Row(
                    //   children: ['A1', 'A2', 'B1'].map((level) {
                    //     final isSelected = _selectedLevel == level;
                    //     return GestureDetector(
                    //       onTap: () => setState(() => _selectedLevel = level),
                    //       child: Container(
                    //         padding: const EdgeInsets.symmetric(horizontal: 12),
                    //         alignment: Alignment.center,
                    //         decoration: BoxDecoration(
                    //           color: isSelected ? Colors.white : Colors.transparent,
                    //           borderRadius: BorderRadius.circular(8),
                    //           boxShadow: isSelected
                    //               ? [const BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))]
                    //               : null,
                    //         ),
                    //         child: Text(
                    //           level,
                    //           style: TextStyle(
                    //             fontFamily: 'Inter',
                    //             fontSize: 14,
                    //             fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    //             color: isSelected ? _AppColors.primary : _AppColors.onSurfaceVariant,
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   }).toList(),
                    // ),
                    const SizedBox(width: 8),

                    // Submit Button
                    GestureDetector(
                      onTap: homeState.isGenerating ? null : _startGeneration,
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF007AFF).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: homeState.isGenerating
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quick Starters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickStarter(
                        'Bakery',
                        'A busy bakery in Berlin during morning rush.',
                      ),
                      _buildQuickStarter(
                        'Train Station',
                        'A rainy evening at a train station in Munich.',
                      ),
                      _buildQuickStarter(
                        'Park',
                        'A sunny weekend at the Tiergarten park.',
                      ),
                    ],
                  ),
                ),

                // Loading Shimmer Effect
                if (homeState.isGenerating)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        height: 4,
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return FractionalTranslation(
                              translation: Offset(
                                (_shimmerController.value * 2) - 1,
                                0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _AppColors.primary.withOpacity(0),
                                      _AppColors.primary.withOpacity(0.5),
                                      _AppColors.primary.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                if (homeState.isGenerating)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'AI is generating...',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      // 5. Bottom Navigation Bar
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              border: Border(
                top: BorderSide(color: Colors.black.withOpacity(0.05)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', true),
                _buildNavItem(Icons.favorite_border, 'Favorites', false),
                _buildNavItem(Icons.person_outline, 'Profile', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(XFile? selectedImage) {
    if (selectedImage == null) {
      return Image.network(
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDR9eU7rCK14myHz-u0nlhSUS3HkBZ-2zXVfrJFSX6gp6kFwV-m6zhKXAKiilZgBZWEX1OiSD2l0TlP849ZK2xLOApNmzFto_S-XF8L88UvJRulwFmtdCs8XJ4pMr9vnqHbk1I0MN1fFfjPmoVNKbvqGpLnNyNhVPgzvRWAyg85p3IhvONuqnR7emZCypM187pcO_aos_FFlX53ZHFakvgurVlRYQUFU37RSUh2dFOtBkN_BjdMHvCeOjlzV8yskYdBXaZRSlgyzkmv',
        fit: BoxFit.cover,
        colorBlendMode: BlendMode.multiply,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.image, size: 64, color: _AppColors.outlineVariant),
      );
    }

    return FutureBuilder<Uint8List>(
      future: selectedImage.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        }
        if (snapshot.hasError) {
          return const Center(
            child: Icon(
              Icons.broken_image,
              size: 64,
              color: _AppColors.outlineVariant,
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // Helper: Frosted Glass Panel
  Widget _buildGlassContainer({
    required Widget child,
    required double radius,
    required EdgeInsets padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: child,
        ),
      ),
    );
  }

  // Helper: Menu Button inside Image Area
  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _AppColors.primary, size: 20),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: _AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Quick Starter Chip
  Widget _buildQuickStarter(String label, String promptData) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _fillPrompt(promptData),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _AppColors.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: _AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Bottom Nav Item 
  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive
                  ? _AppColors.primary
                  : _AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? _AppColors.primary
                    : _AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
