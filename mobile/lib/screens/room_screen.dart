import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

class _RoomScreenState extends State<RoomScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final room = context.read<RoomProvider>().room;
    final expenseProvider = context.read<ExpenseProvider>();
    expenseProvider.setRoom(room);
    await expenseProvider.refresh();
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
        title: const Text('Tabbr'),
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: RoomCodeBanner(
                code: room.code,
                roomName: room.name,
              ),
            ),
            TabBar(
              onTap: (i) => setState(() => _tabIndex = i),
              tabs: const [
                Tab(text: 'Expenses'),
                Tab(text: 'Balance'),
                Tab(text: 'Members'),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: IndexedStack(
                  index: _tabIndex,
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
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openAddExpenseSheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Expense'),
            )
          : _tabIndex == 2
              ? FloatingActionButton.extended(
                  onPressed: _addMember,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Member'),
                )
              : null,
    );
  }
}

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

class _SummaryRow extends StatelessWidget {
  final int memberCount;
  final int expenseCount;
  final int balanceCount;

  const _SummaryRow({
    required this.memberCount,
    required this.expenseCount,
    required this.balanceCount,
  });

  Widget _stat(BuildContext context, String label, int value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
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
        _stat(context, 'Members', memberCount, Icons.group_rounded),
        const SizedBox(width: 8),
        _stat(context, 'Expenses', expenseCount, Icons.receipt_long_rounded),
        const SizedBox(width: 8),
        _stat(context, 'Owed', balanceCount, Icons.swap_horiz_rounded),
      ],
    );
  }
}
