import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/theme.dart';

class RoomCodeBanner extends StatelessWidget {
  final String code;
  final String? roomName;

  const RoomCodeBanner({super.key, required this.code, this.roomName});

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room code copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (roomName != null && roomName!.isNotEmpty) ...[
                  Text(
                    roomName!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.background,
                    ),
                  ),
                  const SizedBox(height: 6),
                ] else
                  const SizedBox(height: 2),
                const Text(
                  'ROOM CODE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppTheme.inkMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    color: AppTheme.background,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: IconButton(
              onPressed: () => _copy(context),
              icon: const Icon(Icons.copy_rounded, color: AppTheme.background),
              tooltip: 'Copy code',
            ),
          ),
        ],
      ),
    );
  }
}