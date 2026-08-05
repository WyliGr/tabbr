import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../providers/room_provider.dart';
import 'room_screen.dart';
import 'server_setup_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
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
      MaterialPageRoute<void>(builder: (_) => const RoomScreen()),
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
      appBar: AppBar(
        title: const Text('Tabbr'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Server settings',
            onPressed: _changeServer,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Tabbr',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Split expenses with your group',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 40),
              if (_showCreateName) ...[
                TextField(
                  controller: _createNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Room name (optional)',
                    hintText: 'Trip to Lisbon',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: loading ? null : _createRoom,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create room'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: loading
                      ? null
                      : () => setState(() => _showCreateName = false),
                  child: const Text('Cancel'),
                ),
              ] else
                FilledButton.icon(
                  onPressed: loading
                      ? null
                      : () => setState(() => _showCreateName = true),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Create a room'),
                ),
              const SizedBox(height: 32),
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.white12)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.white38),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white12)),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Join a room',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _joinCodeController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: const InputDecoration(
                  labelText: 'Room code',
                  hintText: 'ABCDE',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: loading ? null : _joinRoom,
                child: const Text('Join'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
