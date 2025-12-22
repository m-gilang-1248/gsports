import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
          return Center(child: Text('Error loading matches'));
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
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(Icons.sports_tennis, color: AppColors.primary, size: 20),
        ),
        title: Text(
          'Winner: ${match.winner}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${dateFormat.format(match.playedAt)} • ${match.sets.map((s) => "${s.scoreA}-${s.scoreB}").join(", ")}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatDuration(match.durationSeconds),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const Text(
              'Duration',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}
