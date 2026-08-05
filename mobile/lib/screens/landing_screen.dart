import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../config/theme.dart';
import '../providers/room_provider.dart';
import 'room_screen.dart';
import 'server_setup_screen.dart';

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
        transitionDuration: const Duration(milliseconds: 350),
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

  Future<void> _changeServer() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const ServerSetupScreen(),
      ),
    );
    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final loading = roomProvider.status == RoomStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Settings icon top-right
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.settings_rounded),
                tooltip: 'Server settings',
                onPressed: _changeServer,
              ),
            ),
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 80),
                    // Hero logo
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x557C5CFC),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tabbr',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Split expenses with your group',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 56),
                    // ── Create a room card ──
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border),
                        boxShadow: AppTheme.cardShadow(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                'Create a room',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Animated expansion for room name input
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: _showCreateName
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
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
                                      const SizedBox(height: 14),
                                      _gradientButton(
                                        label: 'Create room',
                                        icon: Icons.arrow_forward_rounded,
                                        loading: loading,
                                        onPressed: _createRoom,
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: loading
                                            ? null
                                            : () => setState(() =>
                                                _showCreateName = false),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  )
                                : _gradientButton(
                                    label: 'Start',
                                    icon: Icons.add_circle_outline_rounded,
                                    loading: loading,
                                    onPressed: () =>
                                        setState(() => _showCreateName = true),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // ── Join with code card ──
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border),
                        boxShadow: AppTheme.cardShadow(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceElevated,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.group_add_rounded,
                                  color: AppTheme.textSecondary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                'Join with code',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
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
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                    color: AppTheme.textPrimary,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Room code',
                                    hintText: 'ABCDE',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: loading ? null : _joinRoom,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                  ),
                                  child: const Text('Join'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientButton({
    required String label,
    required IconData icon,
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return Opacity(
      opacity: loading ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: loading ? null : onPressed,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x447C5CFC),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
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