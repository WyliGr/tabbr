import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoomCodeBanner extends StatelessWidget {
  final String code;
  final String? roomName;

  const RoomCodeBanner({super.key, required this.code, this.roomName});

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  'ROOM CODE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  code,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _copy(context),
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy code',
          ),
        ],
      ),
    );
  }
}
