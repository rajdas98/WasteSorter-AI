import 'package:flutter/material.dart';
import 'package:wastesorter/features/badges/presentation/screens/badges_all_screen.dart';
import 'package:wastesorter/features/history/presentation/screens/history_full_screen.dart';
import 'package:wastesorter/features/home/presentation/screens/dashboard_screen.dart';
import 'package:wastesorter/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:wastesorter/features/profile/presentation/screens/profile_screen.dart';

class TabContainer extends StatefulWidget {
  const TabContainer({super.key});

  @override
  State<TabContainer> createState() => _TabContainerState();
}

class _TabContainerState extends State<TabContainer> {
  int _index = 0;

  final List<Widget> _pages = const <Widget>[
    DashboardScreen(),
    HistoryFullScreen(),
    LeaderboardScreen(),
    BadgesAllScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: scheme.surface,
        indicatorColor: const Color(0xFFA5D6A7),
        shadowColor: const Color(0x331B5E20),
        selectedIndex: _index,
        onDestinationSelected: (int value) {
          setState(() => _index = value);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.energy_savings_leaf), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), label: 'Leaderboard'),
          NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), label: 'Badges'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
