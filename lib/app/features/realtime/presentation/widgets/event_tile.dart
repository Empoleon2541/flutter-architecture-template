import 'package:flutter/material.dart';
import '../../domain/entities/realtime_event.dart';

class EventTile extends StatelessWidget {
  final RealtimeEvent event;

  const EventTile({super.key, required this.event});

  Color _getEventColor(BuildContext context) {
    switch (event.type) {
      case 'notification':
        return const Color(0xFF1565C0); // Blue
      case 'price_update':
        return const Color(0xFF2E7D32); // Green
      case 'chat_message':
        return const Color(0xFFE65100); // Orange
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getEventIcon() {
    switch (event.type) {
      case 'notification':
        return Icons.notifications_active;
      case 'price_update':
        return Icons.trending_up;
      case 'chat_message':
        return Icons.chat_bubble;
      default:
        return Icons.circle_notifications;
    }
  }

  String _getEventLabel() {
    switch (event.type) {
      case 'notification':
        return 'Notification';
      case 'price_update':
        return 'Price Update';
      case 'chat_message':
        return 'Chat Message';
      default:
        return 'Event';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 5) return 'just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getEventColor(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getEventIcon(),
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getEventLabel(),
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Timestamp
                        Text(
                          _formatTimestamp(event.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Payload
                    Text(
                      event.payload,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Event ID
                    Text(
                      event.id,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.35),
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
