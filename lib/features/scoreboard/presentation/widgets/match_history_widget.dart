import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/constants/app_constants.dart';
import 'package:gsports/core/presentation/widgets/filters/sport_filter_row.dart';
import 'package:gsports/core/presentation/widgets/filters/time_filter_dropdown.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_result.dart';
import 'package:gsports/features/scoreboard/presentation/bloc/match_history/match_history_bloc.dart';
import 'package:intl/intl.dart';

class MatchHistoryWidget extends StatelessWidget {
  final String userId;

  const MatchHistoryWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.I<MatchHistoryBloc>()..add(LoadMatchHistory(userId)),
      child: BlocBuilder<MatchHistoryBloc, MatchHistoryState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilters(context, state),
              const SizedBox(height: 8),
              if (state.status == MatchHistoryStatus.loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state.status == MatchHistoryStatus.error)
                Center(
                  child: Text(state.errorMessage ?? 'Error loading matches'),
                )
              else if (state.status == MatchHistoryStatus.loaded) ...[
                if (state.filteredMatches.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No matches found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.filteredMatches.length,
                    itemBuilder: (context, index) {
                      final match = state.filteredMatches[index];
                      return _buildMatchCard(context, match);
                    },
                  ),
              ],
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context, MatchHistoryState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Filter:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 8),
              TimeFilterDropdown(
                selectedPreset: state.selectedTimePreset,
                customDate: state.customDate,
                onFilterChanged: (preset, date) {
                  context.read<MatchHistoryBloc>().add(
                    UpdateTimeFilter(preset: preset, customDate: date),
                  );
                },
              ),
            ],
          ),
        ),
        SportFilterRow(
          selectedSportId: state.selectedSportId,
          onSportSelected: (sportId) {
            context.read<MatchHistoryBloc>().add(UpdateSportFilter(sportId));
          },
        ),
      ],
    );
  }

  Widget _buildMatchCard(BuildContext context, MatchResult match) {
    final dateFormat = DateFormat('d MMM yyyy');
    final winnerIds = match.winner == 'Team A'
        ? match.teamAIds
        : match.teamBIds;
    final winnerName = match.winner == 'Team A'
        ? match.teamAName
        : match.teamBName;

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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppConstants.getSportIcon(match.sportType),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (winnerIds.isNotEmpty)
                      _StackedAvatars(uids: winnerIds.take(2).toList()),
                    const SizedBox(height: 4),
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
                    Text(
                      '${dateFormat.format(match.playedAt)} • ${_getScoreSummary(match)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
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

  String _getScoreSummary(MatchResult match) {
    if (match.sets.isEmpty) return 'No score';
    if (match.sets.length == 1) {
      return '${match.sets.first.scoreA} - ${match.sets.first.scoreB}';
    }
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
            left: index * 16.0,
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
