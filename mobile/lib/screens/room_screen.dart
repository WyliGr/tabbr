import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/expense_provider.dart';
import '../providers/room_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/expense_form.dart';
import '../widgets/expense_list.dart';
import '../widgets/member_list.dart';
import '../widgets/room_code_banner.dart';
import 'landing_screen.dart';
import 'server_setup_screen.dart';
import 'settings_screen.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final room = context.read<RoomProvider>().room;
    final expenseProvider = context.read<ExpenseProvider>();
    expenseProvider.setRoom(room);
    await expenseProvider.refresh();
    if (mounted && expenseProvider.members.isEmpty) {
      _tabController.index = 2;
    }
  }

  Future<void> _refresh() async {
    await context.read<ExpenseProvider>().refresh();
  }

  Future<void> _addMember() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add member'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.of(context).accent),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result == null || result.trim().isEmpty || !mounted) return;
    final provider = context.read<ExpenseProvider>();
    final ok = await provider.addMember(result.trim());
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Could not add member'),
        ),
      );
    }
  }

  void _openAddExpenseSheet() {
    final expenseProvider = context.read<ExpenseProvider>();
    if (expenseProvider.members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one member first')),
      );
      _tabController.index = 2;
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ExpenseForm(),
    );
  }

  Future<void> _leaveRoom() async {
    final c = AppColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave room?'),
        content: const Text('You can rejoin later with the same room code.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: c.negative),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    context.read<ExpenseProvider>().setRoom(null);
    await context.read<RoomProvider>().leaveRoom();
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _deleteRoom() async {
    final c = AppColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete room?'),
        content: const Text(
          'This permanently deletes the room, its members and all expenses. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: c.negative),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final roomProvider = context.read<RoomProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    final ok = await roomProvider.deleteCurrentRoom();
    if (!mounted) return;
    if (ok) {
      expenseProvider.setRoom(null);
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(roomProvider.errorMessage ?? 'Could not delete room'),
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
      await _refresh();
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
    final room = context.watch<RoomProvider>().room;
    final c = AppColors.of(context);
    if (room == null) {
      return const LandingScreen();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (room.name != null && room.name!.isNotEmpty)
              ? room.name!
              : 'tabbr',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: c.ink,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  _openSettings();
                  break;
                case 'change_server':
                  _changeServer();
                  break;
                case 'leave':
                  _leaveRoom();
                  break;
                case 'delete':
                  _deleteRoom();
                  break;
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                value: 'settings',
                child: const ListTile(
                  leading: Icon(Icons.settings_rounded),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'change_server',
                child: const ListTile(
                  leading: Icon(Icons.dns_outlined),
                  title: Text('Change server'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'leave',
                child: const ListTile(
                  leading: Icon(Icons.logout_rounded),
                  title: Text('Leave room'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: const ListTile(
                  leading: Icon(Icons.delete_outline_rounded),
                  title: Text('Delete room'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: RoomCodeBanner(
                code: room.code,
                roomName: room.name,
              ),
            ),
            // ── Tab bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _SegmentedTabBar(
                controller: _tabController,
                tabs: const ['Expenses', 'Balance', 'Members'],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: c.accent,
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    ExpenseList(),
                    BalanceCard(),
                    _MembersTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) {
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1.0).animate(anim),
              child: child,
            ),
          );
        },
        child: _buildFab(),
      ),
    );
  }

  Widget? _buildFab() {
    if (_tabController.index == 0) {
      return _GlowFab(
        key: const ValueKey('expense'),
        icon: Icons.add_rounded,
        onPressed: _openAddExpenseSheet,
      );
    } else if (_tabController.index == 2) {
      return _GlowFab(
        key: const ValueKey('member'),
        icon: Icons.person_add_alt_1_rounded,
        onPressed: _addMember,
      );
    }
    return null;
  }
}

/// ── Underline-style segmented tab bar ──────────────────────────
class _SegmentedTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const _SegmentedTabBar({required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.border, width: 1),
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final i = entry.key;
          final label = entry.value;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.animateTo(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedBuilder(
                animation: controller,
                builder: (_, _) {
                  final active = controller.index == i;
                  return Container(
                    padding: const EdgeInsets.only(bottom: 10, top: 6),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: active ? c.accent : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? c.ink : c.inkSecondary,
                        ),
                        child: Text(label),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// ── Circular FAB with accent glow ──────────────────────────────
class _GlowFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _GlowFab({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: 0.4),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: c.accent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(icon, color: c.background, size: 26),
          ),
        ),
      ),
    );
  }
}

/// ── Members tab ──
class _MembersTab extends StatelessWidget {
  const _MembersTab();

  @override
  Widget build(BuildContext context) {
    final members = context.watch<ExpenseProvider>().members;
    final expenses = context.watch<ExpenseProvider>().expenses;
    final balance = context.watch<ExpenseProvider>().balance;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      children: [
        _SummaryRow(
          memberCount: members.length,
          expenseCount: expenses.length,
          balanceCount: balance.entries.length,
        ),
        const SizedBox(height: 12),
        const MemberList(),
      ],
    );
  }
}

/// ── Summary stats row ──
class _SummaryRow extends StatelessWidget {
  final int memberCount;
  final int expenseCount;
  final int balanceCount;

  const _SummaryRow({
    required this.memberCount,
    required this.expenseCount,
    required this.balanceCount,
  });

  Widget _stat(String label, int value, IconData icon, AppColors c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: c.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: c.inkSecondary, size: 16),
            const SizedBox(height: 10),
            Text(
              '$value',
              style: AppTheme.mono(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: c.ink,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTheme.monoLabel(
                fontSize: 9,
                color: c.inkMuted,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      children: [
        _stat('MEMBERS', memberCount, Icons.group_rounded, c),
        const SizedBox(width: 8),
        _stat('EXPENSES', expenseCount, Icons.receipt_long_rounded, c),
        const SizedBox(width: 8),
        _stat('OWED', balanceCount, Icons.swap_horiz_rounded, c),
      ],
    );
  }
}