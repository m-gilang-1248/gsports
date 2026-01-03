import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/constants/app_constants.dart';
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
        // 1. Time Filter Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Filter:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 8),
              _TimeFilterDropdown(state: state),
            ],
          ),
        ),

        // 2. Sport Type Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Semua'),
                  selected: state.selectedSportId == null,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<MatchHistoryBloc>().add(
                        const UpdateSportFilter(null),
                      );
                    }
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: state.selectedSportId == null
                        ? Colors.white
                        : AppColors.primary,
                    fontWeight: state.selectedSportId == null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  showCheckmark: false,
                ),
              ),
              ...AppConstants.sports.map((sport) {
                final isSelected = state.selectedSportId == sport.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(sport.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        context.read<MatchHistoryBloc>().add(
                          UpdateSportFilter(sport.id),
                        );
                      }
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    showCheckmark: false,
                  ),
                );
              }),
            ],
          ),
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
              // 1. Section Kiri: Icon sesuai cabang olahraga
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
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

class _TimeFilterDropdown extends StatelessWidget {
  final MatchHistoryState state;

  const _TimeFilterDropdown({required this.state});

  String _getLabel() {
    switch (state.selectedTimePreset) {
      case TimeFilterPreset.all:
        return 'Semua Waktu';
      case TimeFilterPreset.thisWeek:
        return 'Minggu Ini';
      case TimeFilterPreset.thisMonth:
        return 'Bulan Ini';
      case TimeFilterPreset.customDate:
        return state.customDate != null
            ? DateFormat('dd MMM yyyy').format(state.customDate!)
            : 'Pilih Tanggal';
    }
  }

  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Selesai'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: state.customDate ?? DateTime.now(),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (DateTime newDate) {
                  context.read<MatchHistoryBloc>().add(
                    UpdateTimeFilter(
                      preset: TimeFilterPreset.customDate,
                      customDate: newDate,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TimeFilterPreset>(
      onSelected: (preset) {
        if (preset == TimeFilterPreset.customDate) {
          _showDatePicker(context);
        } else {
          context.read<MatchHistoryBloc>().add(
            UpdateTimeFilter(preset: preset),
          );
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: TimeFilterPreset.all,
          child: Text('Semua Waktu'),
        ),
        const PopupMenuItem(
          value: TimeFilterPreset.thisWeek,
          child: Text('Minggu Ini'),
        ),
        const PopupMenuItem(
          value: TimeFilterPreset.thisMonth,
          child: Text('Bulan Ini'),
        ),
        const PopupMenuItem(
          value: TimeFilterPreset.customDate,
          child: Text('Pilih Tanggal...'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getLabel(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
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
            left:
                index *
                16.0, // Distance overlap (approx -5 from original circle size)
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
