import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../config/theme.dart';
import '../providers/room_provider.dart';
import 'room_screen.dart';
import 'settings_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  final _joinCodeController = TextEditingController();
  final _createNameController = TextEditingController();
  bool _showCreateName = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeAutoJoin();
    });
  }

  Future<void> _maybeAutoJoin() async {
    final config = context.read<ApiConfig>();
    final roomProvider = context.read<RoomProvider>();
    final code = config.currentRoomCode;
    if (code != null && roomProvider.room == null) {
      await roomProvider.verifyRoom(code);
      if (!mounted) return;
      if (roomProvider.room != null) {
        _openRoom();
      }
    }
  }

  @override
  void dispose() {
    _joinCodeController.dispose();
    _createNameController.dispose();
    super.dispose();
  }

  void _openRoom() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, anim, _) => const RoomScreen(),
        transitionsBuilder: (_, anim, _, child) {
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: anim,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _createRoom() async {
    final roomProvider = context.read<RoomProvider>();
    final ok = await roomProvider.createRoom(
      name: _createNameController.text.trim().isEmpty
          ? null
          : _createNameController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      _createNameController.clear();
      setState(() => _showCreateName = false);
      _openRoom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(roomProvider.errorMessage ?? 'Could not create room'),
        ),
      );
    }
  }

  Future<void> _joinRoom() async {
    final code = _joinCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a room code first')),
      );
      return;
    }
    final roomProvider = context.read<RoomProvider>();
    final ok = await roomProvider.joinRoom(code);
    if (!mounted) return;
    if (ok) {
      _joinCodeController.clear();
      _openRoom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(roomProvider.errorMessage ?? 'Could not join room'),
        ),
      );
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final loading = roomProvider.status == RoomStatus.loading;
    final c = AppColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 72),
                    // ── Wordmark ──
                    Center(
                      child: Text(
                        'tabbr',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2.5,
                          color: c.ink,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'split expenses,\nkeep it simple',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: c.inkSecondary,
                      ),
                    ),
                    const SizedBox(height: 64),
                    // ── Create a room ──
                    _ActionCard(
                      label: 'Create a room',
                      subtext: 'Start a new expense group',
                      icon: Icons.add_rounded,
                      accent: c.accent,
                      accentBg: c.accentSoft,
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: _showCreateName
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextField(
                                    controller: _createNameController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      labelText: 'Room name (optional)',
                                      hintText: 'Trip to Lisbon',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _PrimaryButton(
                                    label: 'Create room',
                                    loading: loading,
                                    onPressed: _createRoom,
                                  ),
                                  TextButton(
                                    onPressed: loading
                                        ? null
                                        : () => setState(
                                            () => _showCreateName = false),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              )
                            : _PrimaryButton(
                                label: 'Get started',
                                icon: Icons.arrow_forward_rounded,
                                loading: loading,
                                onPressed: () =>
                                    setState(() => _showCreateName = true),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ── Join with code ──
                    _ActionCard(
                      label: 'Join with code',
                      subtext: 'Enter a code shared with you',
                      icon: Icons.group_add_rounded,
                      accent: c.positive,
                      accentBg: c.positiveSoft,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _joinCodeController,
                              textCapitalization:
                                  TextCapitalization.characters,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Za-z0-9]')),
                                LengthLimitingTextInputFormatter(8),
                              ],
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: c.ink,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Room code',
                                hintText: 'ABCD12',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: loading ? null : _joinRoom,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22),
                                backgroundColor: c.ink,
                                foregroundColor: c.background,
                                side: BorderSide.none,
                              ),
                              child: const Text('Join'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            // ── Settings button (on top of ScrollView so it's tappable) ──
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Settings',
                onPressed: _openSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── Reusable card with accent label + icon ─────────────────────
class _ActionCard extends StatelessWidget {
  final String label;
  final String subtext;
  final IconData icon;
  final Color accent;
  final Color accentBg;
  final Widget child;

  const _ActionCard({
    required this.label,
    required this.subtext,
    required this.icon,
    required this.accent,
    required this.accentBg,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: c.ink,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtext,
                      style: TextStyle(
                        fontSize: 13,
                        color: c.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

/// ── Primary button (ink filled) ────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool loading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    this.icon,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Opacity(
      opacity: loading ? 0.6 : 1.0,
      child: Material(
        color: c.ink,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: loading ? null : onPressed,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.background,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: c.background, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: c.background,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}