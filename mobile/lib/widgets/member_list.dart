import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/member.dart';
import '../providers/expense_provider.dart';

/// Design tokens (kept local so widgets render correctly regardless of theme).
class _T {
  static const surface = Color(0xFF1A1D24);
  static const surfaceElevated = Color(0xFF22262E);
  static const primary = Color(0xFF7C5CFC);
  static const negative = Color(0xFFFF6B6B);
  static const textPrimary = Color(0xFFF5F7FA);
  static const textSecondary = Color(0xFF8B92A5);
  static const textMuted = Color(0xFF5C6378);
}

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: provider.members.length,
          itemBuilder: (context, index) {
            final member = provider.members[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MemberTile(
                key: ValueKey(member.id),
                member: member,
                index: index,
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyMembers extends StatelessWidget {
  const _EmptyMembers();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _T.primary.withValues(alpha: 0.12),
                    border: Border.all(
                      color: _T.primary.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.group_rounded,
                    size: 40,
                    color: _T.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No members yet',
                  style: TextStyle(
                    color: _T.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add people to start splitting\nexpenses together',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _T.textSecondary,
                    fontSize: 14,
                    height: 1.4,
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

class _MemberLoading extends StatelessWidget {
  const _MemberLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final Member member;
  final int index;

  const _MemberTile({
    super.key,
    required this.member,
    required this.index,
  });

  Color _avatarColor() {
    const colors = [
      Color(0xFF7C5CFC),
      Color(0xFFFF6B6B),
      Color(0xFF2DD4A7),
      Color(0xFF5B8DEF),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
    ];
    return colors[member.id.abs() % colors.length];
  }

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
        backgroundColor: _T.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Remove member?',
          style: TextStyle(
            color: _T.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Remove ${member.name} from this room? This cannot be undone.',
          style: const TextStyle(color: _T.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _T.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: _T.negative),
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
              context.read<ExpenseProvider>().errorMessage ??
                  'Failed to remove',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Colored avatar with initials
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _avatarColor(),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    _initials(member.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name + role label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _T.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'MEMBER',
                      style: TextStyle(
                        color: _T.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Subtle delete
              GestureDetector(
                onTap: () => _confirmDelete(context),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: _T.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}