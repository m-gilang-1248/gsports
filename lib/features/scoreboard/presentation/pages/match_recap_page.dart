import 'package:cloud_firestore/cloud_firestore.dart';
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
      backgroundColor: AppColors.primary, // Background for the "header" feel
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Match Recap',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.emoji_events_outlined,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Header Info
                    _buildHeaderInfo(context, dateFormat, timeFormat),
                    const SizedBox(height: 32),

                    // Section 2: Players & Teams
                    _buildTeamsSection(context),
                    const SizedBox(height: 32),

                    // Section 3: Match Summary
                    _buildMatchSummary(context),
                    const SizedBox(height: 50), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(
    BuildContext context,
    DateFormat dateFormat,
    DateFormat timeFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                match.sportType.toUpperCase(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800, // ExtraBold
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                match.venueName ?? 'Venue Unknown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, // H3 equivalent
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
        const SizedBox(height: 20),
        Text(
          dateFormat.format(match.playedAt),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, // H3
            color: Colors.grey[800],
          ),
        ),
        if (match.startTime != null && match.endTime != null)
          Text(
            '${timeFormat.format(match.startTime!)} - ${timeFormat.format(match.endTime!)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold, // H1 equivalent for time
              color: Colors.black,
            ),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        ...playerIds.map((uid) {
          final name = match.playerNames[uid] ?? 'Player';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: isTeamA
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                if (isTeamA) ...[
                  _UserAvatar(uid: uid, radius: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _UserAvatar(uid: uid, radius: 14),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
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
              'Match Duration',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              _formatDuration(match.durationSeconds),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Score History',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: match.sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            final isTeamAWin = set.scoreA > set.scoreB;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold, // H3 style
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isTeamAWin
                                ? Colors.cyanAccent
                                : Colors.deepOrangeAccent)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          (isTeamAWin
                                  ? Colors.cyanAccent
                                  : Colors.deepOrangeAccent)
                              .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${set.scoreA} - ${set.scoreB}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isTeamAWin
                          ? Colors.cyan[800]
                          : Colors.deepOrange[800],
                    ),
                  ),
                ),
              ],
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
              name[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
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
