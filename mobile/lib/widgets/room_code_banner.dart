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
    final c = AppColors.of(context);
    // Dark-only: the banner uses surface color with a hairline border.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: c.border, width: 1),
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: c.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                ] else
                  const SizedBox(height: 2),
                Text(
                  'ROOM CODE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: c.inkMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    color: c.ink,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: c.surfaceDim,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: IconButton(
              onPressed: () => _copy(context),
              icon: Icon(Icons.copy_rounded, color: c.inkSecondary),
              tooltip: 'Copy code',
            ),
          ),
        ],
      ),
    );
  }
}