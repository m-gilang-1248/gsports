import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_result.dart';
import 'package:gsports/features/scoreboard/domain/repositories/scoreboard_repository.dart';
import 'package:intl/intl.dart';

class MatchHistoryWidget extends StatelessWidget {
  final String userId;

  const MatchHistoryWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.I<ScoreboardRepository>().getMatchesByUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading matches'));
        }

        final result = snapshot.data;
        if (result == null) return const SizedBox.shrink();

        return result.fold((failure) => Center(child: Text(failure.message)), (
          matches,
        ) {
          if (matches.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No matches played yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          // Sort matches by date descending
          final sortedMatches = List<MatchResult>.from(matches)
            ..sort((a, b) => b.playedAt.compareTo(a.playedAt));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Riwayat Pertandingan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedMatches.length,
                itemBuilder: (context, index) {
                  final match = sortedMatches[index];
                  return _buildMatchCard(context, match);
                },
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildMatchCard(BuildContext context, MatchResult match) {
    final dateFormat = DateFormat('d MMM yyyy');
    final winnerIds = match.winner == 'Team A' ? match.teamAIds : match.teamBIds;
    final winnerName =
        match.winner == 'Team A' ? match.teamAName : match.teamBName;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/match-recap', extra: match),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 1. Section Kiri: Icon sesuai cabang olahraga
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSportIcon(match.sportType),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // 2. Section Tengah: 3 Baris
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Atas: Stacked Avatars
                    if (winnerIds.isNotEmpty)
                      _StackedAvatars(uids: winnerIds.take(2).toList()),
                    const SizedBox(height: 4),
                    // Baris Tengah: Winner Name
                    Text(
                      'Winner: $winnerName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Baris Bawah: Tanggal & Poin
                    Text(
                      '${dateFormat.format(match.playedAt)} • ${_getScoreSummary(match)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Section Kanan: Durasi
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDuration(match.durationSeconds),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    'Durasi',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSportIcon(String sportType) {
    final type = sportType.toLowerCase();
    if (type.contains('badminton')) return Icons.sports_tennis;
    if (type.contains('futsal') || type.contains('soccer')) {
      return Icons.sports_soccer;
    }
    if (type.contains('basketball')) return Icons.sports_basketball;
    if (type.contains('volleyball')) return Icons.sports_volleyball;
    return Icons.sports_handball;
  }

  String _getScoreSummary(MatchResult match) {
    if (match.sets.isEmpty) return 'No score';
    // If it's a timed game like futsal, just show the last "set" score
    if (match.sets.length == 1) {
      return '${match.sets.first.scoreA} - ${match.sets.first.scoreB}';
    }
    // For badminton, show summary of sets
    return match.sets.map((s) => '${s.scoreA}-${s.scoreB}').join(', ');
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}

class _StackedAvatars extends StatelessWidget {
  final List<String> uids;
  const _StackedAvatars({required this.uids});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Stack(
        children: List.generate(uids.length, (index) {
          return Positioned(
            left: index * 16.0, // Distance overlap (approx -5 from original circle size)
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: _UserAvatar(uid: uids[index], radius: 10),
            ),
          );
        }),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String uid;
  final double radius;
  const _UserAvatar({required this.uid, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data();
          final photoUrl = data?['photoUrl'] as String?;
          final name = data?['displayName'] as String? ?? 'U';

          if (photoUrl != null && photoUrl.isNotEmpty) {
            return CircleAvatar(
              radius: radius,
              backgroundImage: NetworkImage(photoUrl),
            );
          }
          return CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: radius * 1.0,
              ),
            ),
          );
        }
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.person, color: Colors.grey, size: radius),
        );
      },
    );
  }
}