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
    // Auto-switch to Members tab if the room has no members yet.
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
      // Switch to Members tab so the user can add one.
      _tabController.index = 2;
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExpenseForm(),
    );
  }

  Future<void> _leaveRoom() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave room?'),
        content: const Text(
          'You can rejoin later with the same room code.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
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

  @override
  Widget build(BuildContext context) {
    final room = context.watch<RoomProvider>().room;
    if (room == null) {
      return const LandingScreen();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (room.name != null && room.name!.isNotEmpty)
              ? room.name!
              : 'Tabbr',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              switch (value) {
                case 'change_server':
                  _changeServer();
                case 'leave':
                  _leaveRoom();
                case 'delete':
                  _deleteRoom();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'change_server',
                child: ListTile(
                  leading: Icon(Icons.cloud_outlined),
                  title: Text('Change server'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'leave',
                child: ListTile(
                  leading: Icon(Icons.logout_rounded),
                  title: Text('Leave room'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: RoomCodeBanner(
                code: room.code,
                roomName: room.name,
              ),
            ),
            // Pill-style TabBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _PillTabBar(
                controller: _tabController,
                tabs: const ['Expenses', 'Balance', 'Members'],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: AppTheme.primaryAccent,
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
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) {
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(anim),
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
      return _GradientFab(
        key: const ValueKey('expense'),
        icon: Icons.add_rounded,
        label: 'Expense',
        onPressed: _openAddExpenseSheet,
      );
    } else if (_tabController.index == 2) {
      return _GradientFab(
        key: const ValueKey('member'),
        icon: Icons.person_add_alt_1_rounded,
        label: 'Member',
        onPressed: _addMember,
      );
    }
    return null;
  }
}

// ── Pill-style tab bar with rounded background behind active tab ──
class _PillTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const _PillTabBar({required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;
          return Stack(
            children: [
              // Animated pill indicator
              AnimatedBuilder(
                animation: controller,
                builder: (_, _) {
                  final left = controller.offset * tabWidth +
                      controller.index * tabWidth;
                  return Positioned(
                    left: left,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x337C5CFC),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Tab labels
              Row(
                children: tabs.asMap().entries.map((entry) {
                  final i = entry.key;
                  final label = entry.value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.animateTo(i),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: controller,
                          builder: (_, _) {
                            final active = controller.index == i;
                            return Text(
                              label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: active
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Gradient FAB ──
class _GradientFab extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _GradientFab({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.fabShadow(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
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
    );
  }
}

// ── Members tab ──
class _MembersTab extends StatelessWidget {
  const _MembersTab();

  @override
  Widget build(BuildContext context) {
    final members = context.watch<ExpenseProvider>().members;
    final expenses = context.watch<ExpenseProvider>().expenses;
    final balance = context.watch<ExpenseProvider>().balance;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      children: [
        _SummaryRow(
          memberCount: members.length,
          expenseCount: expenses.length,
          balanceCount: balance.entries.length,
        ),
        const SizedBox(height: 16),
        const MemberList(),
      ],
    );
  }
}

// ── Summary stats row ──
class _SummaryRow extends StatelessWidget {
  final int memberCount;
  final int expenseCount;
  final int balanceCount;

  const _SummaryRow({
    required this.memberCount,
    required this.expenseCount,
    required this.balanceCount,
  });

  Widget _stat(String label, int value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryAccent, size: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stat('Members', memberCount, Icons.group_rounded),
        const SizedBox(width: 10),
        _stat('Expenses', expenseCount, Icons.receipt_long_rounded),
        const SizedBox(width: 10),
        _stat('Owed', balanceCount, Icons.swap_horiz_rounded),
      ],
    );
  }
}