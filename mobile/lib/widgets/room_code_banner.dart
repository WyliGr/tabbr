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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C5CFC), Color(0xFF5B8DEF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x337C5CFC),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                ] else
                  const SizedBox(height: 4),
                Text(
                  'ROOM CODE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: () => _copy(context),
              icon: const Icon(Icons.copy_rounded, color: Colors.white),
              tooltip: 'Copy code',
            ),
          ),
        ],
      ),
    );
  }
}