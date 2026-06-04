import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const _tabs = [
    _TabItem(label: 'Posts', icon: Icons.article_outlined, activeIcon: Icons.article),
    _TabItem(label: 'Real-Time', icon: Icons.wifi_outlined, activeIcon: Icons.wifi),
    _TabItem(label: 'Profile', icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  String _titleFor(int index) => switch (index) {
        0 => 'Posts',
        1 => 'Real-Time Feed',
        2 => 'Profile',
        _ => 'Architecture Kit',
      };

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(index)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'BLoC + Clean Arch',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => _onTap(context, i),
        items: _tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  activeIcon: Icon(t.activeIcon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    // Use goBranch to preserve per-tab navigation state
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
