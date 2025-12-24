import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_result.dart';

class MatchRecapPage extends StatelessWidget {
  final MatchResult match;

  const MatchRecapPage({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pertandingan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Header
            _buildHeader(context, dateFormat, timeFormat),
            const SizedBox(height: 32),

            // Section 2: Players & Teams
            _buildTeamsSection(context),
            const SizedBox(height: 32),

            // Section 3: Match Summary
            _buildMatchSummary(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    DateFormat dateFormat,
    DateFormat timeFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          match.sportType.toUpperCase(),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                match.venueName ?? 'Venue Tidak Diketahui',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (match.courtName != null) ...[
                const SizedBox(height: 4),
                Text(
                  match.courtName!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          dateFormat.format(match.playedAt),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(height: 4),
        if (match.startTime != null && match.endTime != null)
          Text(
            '${timeFormat.format(match.startTime!)} - ${timeFormat.format(match.endTime!)}',
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  Widget _buildTeamsSection(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Team A
          Expanded(child: _buildTeamColumn(context, true)),
          const VerticalDivider(width: 32, thickness: 1),
          // Team B
          Expanded(child: _buildTeamColumn(context, false)),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(BuildContext context, bool isTeamA) {
    final teamName = isTeamA ? match.teamAName : match.teamBName;
    final playerIds = isTeamA ? match.teamAIds : match.teamBIds;
    final isWinner = isTeamA
        ? match.winner == 'Team A'
        : match.winner == 'Team B';

    return Column(
      crossAxisAlignment: isTeamA
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          teamName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: isTeamA ? TextAlign.left : TextAlign.right,
        ),
        const SizedBox(height: 8),
        ...playerIds.map((uid) {
          final name = match.playerNames[uid] ?? 'Pemain';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: isTeamA ? TextAlign.left : TextAlign.right,
            ),
          );
        }),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isWinner
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isWinner ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Text(
            isWinner ? 'WIN' : 'LOSE',
            style: TextStyle(
              color: isWinner ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Durasi Pertandingan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              _formatDuration(match.durationSeconds),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Hasil Per Set',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: match.sets.map((set) {
            final isTeamAWin = set.scoreA > set.scoreB;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color:
                    (isTeamAWin ? Colors.cyanAccent : Colors.deepOrangeAccent)
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      (isTeamAWin ? Colors.cyanAccent : Colors.deepOrangeAccent)
                          .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '${set.scoreA} - ${set.scoreB}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isTeamAWin ? Colors.cyan[700] : Colors.deepOrange[700],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}
