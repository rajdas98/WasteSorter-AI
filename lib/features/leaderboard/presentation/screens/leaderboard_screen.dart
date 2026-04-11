import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wastesorter/features/leaderboard/presentation/providers/leaderboard_providers.dart';
import 'package:wastesorter/features/profile/data/models/user_model.dart';

/// Emerald-themed real-time leaderboard from Firestore `users` (by `totalPoints`).
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  static const Color _emeraldLight = Color(0xFFA5D6A7);
  static const Color _surfaceTint = Color(0xFFF4FFF9);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUsers = ref.watch(leaderboardUsersProvider);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco-Warriors'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[_surfaceTint, Color(0xFFE8F5E9)],
          ),
        ),
        child: asyncUsers.when(
          data: (List<UserModel> users) {
            if (users.isEmpty) {
              return const Center(
                child: Text(
                  'No players yet.\nComplete a scan and collect points!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF2E7D32)),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: users.length,
              itemBuilder: (BuildContext context, int index) {
                final int rank = index + 1;
                final UserModel u = users[index];
                return _LeaderboardTile(rank: rank, user: u);
              },
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: scheme.primary),
          ),
          error: (Object err, StackTrace _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.cloud_off_outlined, size: 48, color: scheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Could not load leaderboard',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    err.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.rank, required this.user});

  final int rank;
  final UserModel user;

  String _rankLabel() {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTopThree = rank <= 3;
    return Card(
      elevation: isTopThree ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: isTopThree ? const Color(0xFFE8F5E9) : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: SizedBox(
          width: 44,
          child: Center(
            child: Text(
              _rankLabel(),
                style: TextStyle(
                fontSize: isTopThree ? 28 : 18,
                fontWeight: FontWeight.w700,
                color: isTopThree ? Theme.of(context).colorScheme.primary : Colors.black87,
              ),
            ),
          ),
        ),
        title: Text(
          user.displayName.isEmpty ? 'Eco Hero' : user.displayName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        subtitle: Text(
          user.level,
          style: const TextStyle(fontSize: 12, color: Color(0xFF388E3C)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: LeaderboardScreen._emeraldLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            '${user.totalPoints} pts',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
