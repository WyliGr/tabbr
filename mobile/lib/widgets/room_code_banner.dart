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
    // Match the mockup: accent/30 border, accent/5 bg, rounded-xl,
    // code in mono with wide letter spacing.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: c.accentSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: c.accentBorder, width: 1),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  'ROOM CODE',
                  style: AppTheme.monoLabel(
                    fontSize: 9,
                    color: c.inkMuted,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  code,
                  style: AppTheme.mono(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: c.ink,
                    letterSpacing: 4,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: () => _copy(context),
              icon: Icon(Icons.copy_rounded, color: c.inkSecondary, size: 18),
              tooltip: 'Copy code',
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}