import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../config/theme.dart';
import '../config/theme_provider.dart';
import 'server_setup_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final config = context.watch<ApiConfig>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: c.ink,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Appearance ──
              _SectionHeader(title: 'APPEARANCE'),
              const SizedBox(height: 10),
              _SettingsCard(
                children: [
                  _AccentColorRow(),
                ],
              ),
              const SizedBox(height: 32),

              // ── Server ──
              _SectionHeader(title: 'SERVER'),
              const SizedBox(height: 10),
              _SettingsCard(
                children: [
                  _ServerRow(
                    serverUrl: config.serverUrl,
                    onTap: () => _navigateToServerSetup(context),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── About ──
              _SectionHeader(title: 'ABOUT'),
              const SizedBox(height: 10),
              _SettingsCard(
                children: [
                  _AboutRow(
                    label: 'Version',
                    value: '1.0.0',
                  ),
                  _DividerLine(),
                  _AboutRow(
                    label: 'App',
                    value: 'Tabbr',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToServerSetup(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const ServerSetupScreen(),
      ),
    );
    if (changed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server updated')),
      );
    }
  }
}

// ──────────────────────────────────────────────────────────────
//  Accent color row
// ──────────────────────────────────────────────────────────────
class _AccentColorRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return InkWell(
      onTap: () => _showAccentPicker(context),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Current accent circle
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: themeProvider.accentColor,
                shape: BoxShape.circle,
                border: Border.all(color: c.borderStrong, width: 1),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Accent color',
                style: TextStyle(
                  color: c.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: c.inkMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showAccentPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => const _AccentPickerSheet(),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Accent picker bottom sheet
// ──────────────────────────────────────────────────────────────
class _AccentPickerSheet extends StatelessWidget {
  const _AccentPickerSheet();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final currentHex = themeProvider.accentHex;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: c.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'ACCENT COLOR',
            style: TextStyle(
              color: c.inkMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            itemCount: AppTheme.accentPresets.length,
            itemBuilder: (context, index) {
              final hex = AppTheme.accentPresets[index];
              final name = AppTheme.accentPresetNames[index];
              final isSelected = hex == currentHex;

              return GestureDetector(
                onTap: () {
                  themeProvider.setAccent(hex);
                  Navigator.of(context).pop();
                },
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(hex),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? c.ink
                              : c.border,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              color: _needsWhiteText(hex)
                                  ? Colors.white
                                  : Colors.black,
                              size: 22,
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? c.ink : c.inkSecondary,
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Determine whether a checkmark icon should be white or black
  /// based on the luminance of the background color.
  bool _needsWhiteText(int hex) {
    return Color(hex).computeLuminance() < 0.5;
  }
}

// ──────────────────────────────────────────────────────────────
//  Server row
// ──────────────────────────────────────────────────────────────
class _ServerRow extends StatelessWidget {
  final String serverUrl;
  final VoidCallback onTap;

  const _ServerRow({required this.serverUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.dns_outlined, color: c.inkSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change server',
                    style: TextStyle(
                      color: c.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    serverUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.inkMuted,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: c.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  About row
// ──────────────────────────────────────────────────────────────
class _AboutRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: c.inkSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: c.ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Reusable building blocks
// ──────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: c.inkMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const _DividerLine(),
          ],
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: c.border,
      ),
    );
  }
}