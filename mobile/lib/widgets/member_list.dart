import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/member.dart';
import '../providers/expense_provider.dart';

class MemberList extends StatelessWidget {
  const MemberList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.members.isEmpty) {
          return const _MemberLoading();
        }
        if (provider.members.isEmpty) {
          return const _EmptyMembers();
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: provider.members.length,
          itemBuilder: (context, index) {
            final member = provider.members[index];
            final isLast = index == provider.members.length - 1;
            return _MemberRow(
              key: ValueKey(member.id),
              member: member,
              showBottomBorder: !isLast,
            );
          },
        );
      },
    );
  }
}

/// ── Empty state ───────────────────────────────────────────────
class _EmptyMembers extends StatelessWidget {
  const _EmptyMembers();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surfaceDim,
              ),
              child: Icon(
                Icons.person_add_outlined,
                size: 26,
                color: c.inkSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No members yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: c.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add people to start splitting',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.inkSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── Loading state ─────────────────────────────────────────────
class _MemberLoading extends StatelessWidget {
  const _MemberLoading();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 4,
      itemBuilder: (context, index) => Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: index < 3 ? c.border : Colors.transparent,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// ── Member row (bordered, not card) ───────────────────────────
class _MemberRow extends StatelessWidget {
  final Member member;
  final bool showBottomBorder;

  const _MemberRow({
    super.key,
    required this.member,
    required this.showBottomBorder,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final c = AppColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove member?'),
        content: Text('Remove ${member.name} from this room? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: c.negative),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final ok = await context.read<ExpenseProvider>().deleteMember(member.id);
      if (!context.mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<ExpenseProvider>().errorMessage ?? 'Failed to remove',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: showBottomBorder ? c.border : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          // ── Avatar (circle) ──
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.avatarColor(member.id),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials(member.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // ── Name ──
          Expanded(
            child: Text(
              member.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c.ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
          // ── Remove ──
          GestureDetector(
            onTap: () => _confirmDelete(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: c.inkMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}