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
            return _MemberTile(
              key: ValueKey(member.id),
              member: member,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceDim,
              ),
              child: const Icon(
                Icons.person_add_outlined,
                size: 30,
                color: AppTheme.inkSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No members yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add people to start\nsplitting together',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.inkSecondary,
                fontSize: 14,
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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDim,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      ),
    );
  }
}

/// ── Member tile ───────────────────────────────────────────────
class _MemberTile extends StatelessWidget {
  final Member member;

  const _MemberTile({super.key, required this.member});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _confirmDelete(BuildContext context) async {
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
            style: TextButton.styleFrom(foregroundColor: AppTheme.negative),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // ── Avatar ──
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.avatarColor(member.id),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Center(
                child: Text(
                  _initials(member.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ── Name ──
            Expanded(
              child: Text(
                member.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            // ── Remove ──
            GestureDetector(
              onTap: () => _confirmDelete(context),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppTheme.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}