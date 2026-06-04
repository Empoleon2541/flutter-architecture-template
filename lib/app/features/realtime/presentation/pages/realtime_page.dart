import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/realtime_bloc.dart';
import '../bloc/realtime_bloc_event.dart';
import '../bloc/realtime_bloc_state.dart';
import '../widgets/event_tile.dart';

class RealtimePage extends StatelessWidget {
  const RealtimePage({super.key});

  static const path = '/realtime';
  static const name = 'realtime';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<RealtimeBloc, RealtimeBlocState>(
      builder: (context, state) {
        final isConnected = state is RealtimeConnected;
        final isConnecting = state is RealtimeConnecting;
        final events =
            isConnected ? (state as RealtimeConnected).events : [];

        return Column(
          children: [
            // Status & Control Bar
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  // Status Indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected
                          ? const Color(0xFF4CAF50)
                          : isConnecting
                              ? const Color(0xFFFFC107)
                              : const Color(0xFF9E9E9E),
                      boxShadow: isConnected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected
                        ? 'Connected • ${events.length} events'
                        : isConnecting
                            ? 'Connecting...'
                            : state is RealtimeDisconnected
                                ? 'Disconnected'
                                : state is RealtimeError
                                    ? 'Error'
                                    : 'Not connected',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),

                  // Connect/Disconnect button
                  if (isConnecting)
                    const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        if (isConnected) {
                          context
                              .read<RealtimeBloc>()
                              .add(const RealtimeDisconnectRequested());
                        } else {
                          context
                              .read<RealtimeBloc>()
                              .add(const RealtimeConnectRequested());
                        }
                      },
                      icon: Icon(
                        isConnected ? Icons.wifi_off : Icons.wifi,
                        size: 16,
                      ),
                      label: Text(isConnected ? 'Disconnect' : 'Connect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isConnected
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Info bar
            if (isConnected)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: const Color(0xFF4CAF50).withOpacity(0.08),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Mock WebSocket emitting events every 3 seconds. Max 50 events shown.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Legend row
            if (isConnected && events.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(
                      color: const Color(0xFF1565C0),
                      label: 'Notification',
                      icon: Icons.notifications_active,
                    ),
                    const SizedBox(width: 12),
                    _LegendItem(
                      color: const Color(0xFF2E7D32),
                      label: 'Price',
                      icon: Icons.trending_up,
                    ),
                    const SizedBox(width: 12),
                    _LegendItem(
                      color: const Color(0xFFE65100),
                      label: 'Chat',
                      icon: Icons.chat_bubble,
                    ),
                  ],
                ),
              ),

            // Event List
            Expanded(
              child: _buildEventList(context, state, events, theme),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventList(
    BuildContext context,
    RealtimeBlocState state,
    List<dynamic> events,
    ThemeData theme,
  ) {
    if (state is RealtimeInitial) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_find,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Real-Time Event Feed',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Connect" to start receiving\nmock WebSocket events',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state is RealtimeDisconnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Disconnected',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Connect" to reconnect',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    if (state is RealtimeError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Connection Error', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context
                    .read<RealtimeBloc>()
                    .add(const RealtimeConnectRequested()),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is RealtimeConnecting || (state is RealtimeConnected && events.isEmpty)) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Waiting for events...'),
          ],
        ),
      );
    }

    if (state is RealtimeConnected) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return EventTile(event: events[index]);
        },
      );
    }

    return const SizedBox.shrink();
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
