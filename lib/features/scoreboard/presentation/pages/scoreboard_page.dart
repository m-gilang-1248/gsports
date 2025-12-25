import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsports/features/scoreboard/presentation/bloc/scoreboard_bloc.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_result.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:go_router/go_router.dart';

class ScoreboardPage extends StatelessWidget {
  final String bookingId;
  final String sportType;
  final List<String> players;
  final List<String> teamA;
  final List<String> teamB;
  final String teamAName;
  final String teamBName;
  final Map<String, String> playerNames;
  final String? venueName;
  final String? courtName;
  final DateTime? startTime;
  final DateTime? endTime;

  const ScoreboardPage({
    super.key,
    required this.bookingId,
    required this.sportType,
    required this.players,
    required this.teamA,
    required this.teamB,
    required this.teamAName,
    required this.teamBName,
    required this.playerNames,
    this.venueName,
    this.courtName,
    this.startTime,
    this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<ScoreboardBloc>(),
      child: _ScoreboardView(
        bookingId: bookingId,
        sportType: sportType,
        players: players,
        teamA: teamA,
        teamB: teamB,
        teamAName: teamAName,
        teamBName: teamBName,
        playerNames: playerNames,
        venueName: venueName,
        courtName: courtName,
        startTime: startTime,
        endTime: endTime,
      ),
    );
  }
}

class _ScoreboardView extends StatefulWidget {
  final String bookingId;
  final String sportType;
  final List<String> players;
  final List<String> teamA;
  final List<String> teamB;
  final String teamAName;
  final String teamBName;
  final Map<String, String> playerNames;
  final String? venueName;
  final String? courtName;
  final DateTime? startTime;
  final DateTime? endTime;

  const _ScoreboardView({
    required this.bookingId,
    required this.sportType,
    required this.players,
    required this.teamA,
    required this.teamB,
    required this.teamAName,
    required this.teamBName,
    required this.playerNames,
    this.venueName,
    this.courtName,
    this.startTime,
    this.endTime,
  });

  @override
  State<_ScoreboardView> createState() => _ScoreboardViewState();
}

class _ScoreboardViewState extends State<_ScoreboardView> {
  int _secondsElapsed = 0;

  late Stream<int> _timerStream;
  late StreamSubscription<int> _timerSubscription;

  @override
  void initState() {
    super.initState();

    // Initialize scoring logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ScoreboardBloc>().add(
          InitializeScoreboard(widget.sportType),
        );
      }
    });

    _timerStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
    _timerSubscription = _timerStream.listen((_) {
      if (!mounted) return;
      final state = context.read<ScoreboardBloc>().state;
      if (!state.isTimerPaused && !state.isMatchFinished) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });

    // Enable Wakelock to keep screen on
    WakelockPlus.enable();
    // Force Landscape for better experience (optional but recommended for scoreboard)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _timerSubscription.cancel();
    WakelockPlus.disable();
    // Restore orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocConsumer<ScoreboardBloc, ScoreboardState>(
          listener: (context, state) {
            if (state.isMatchFinished) {
              _showFinishDialog(context, state);
            }
            // Auto finish if time is up for timed sports
            if (state.isTimed &&
                !state.isMatchFinished &&
                _secondsElapsed >= (state.targetDurationMinutes * 60) &&
                state.targetDurationMinutes > 0) {
              _showTimeUpDialog(context, state);
            }
            if (state.saveSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Match result saved!'),
                  backgroundColor: Colors.green,
                ),
              );

              final matchResult = MatchResult(
                id: '',
                bookingId: widget.bookingId,
                sportType: widget.sportType,
                playedAt: DateTime.now(),
                durationSeconds: _secondsElapsed,
                players: widget.players,
                teamAIds: widget.teamA,
                teamBIds: widget.teamB,
                teamAName: widget.teamAName,
                teamBName: widget.teamBName,
                playerNames: widget.playerNames,
                venueName: widget.venueName,
                courtName: widget.courtName,
                startTime: widget.startTime,
                endTime: widget.endTime,
                sets: state.historySets,
                winner: state.winner!,
              );

              context.pushReplacement('/match-recap', extra: matchResult);
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.errorMessage}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Stack(
                children: [
                  Row(
                    children: [
                      // Team A (Left)
                      Expanded(
                        child: _buildScorePanel(
                          context,
                          label: widget.teamAName,
                          score: state.scoreA,
                          playerNames: widget.teamA
                              .map((id) => widget.playerNames[id] ?? 'Unknown')
                              .join(', '),
                          color: Colors.cyanAccent,
                          onTap: () => context.read<ScoreboardBloc>().add(
                                IncrementScoreA(),
                              ),
                          onDecrement: () => context.read<ScoreboardBloc>().add(
                                DecrementScoreA(),
                              ),
                        ),
                      ),
                      // Divider & Info (Center)
                      Container(width: 2, color: Colors.grey[800]),
                      // Team B (Right)
                      Expanded(
                        child: _buildScorePanel(
                          context,
                          label: widget.teamBName,
                          score: state.scoreB,
                          playerNames: widget.teamB
                              .map((id) => widget.playerNames[id] ?? 'Unknown')
                              .join(', '),
                          color: Colors.deepOrangeAccent,
                          onTap: () => context.read<ScoreboardBloc>().add(
                                IncrementScoreB(),
                              ),
                          onDecrement: () => context.read<ScoreboardBloc>().add(
                                DecrementScoreB(),
                              ),
                        ),
                      ),
                    ],
                  ),

                  // Overlay Controls (Center Top)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.usesSets)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'SET ${state.currentSet}',
                                style: GoogleFonts.orbitron(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatDuration(_secondsElapsed),
                                style: GoogleFonts.orbitron(
                                  color: state.isTimerPaused
                                      ? Colors.orangeAccent
                                      : Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => context
                                    .read<ScoreboardBloc>()
                                    .add(ToggleTimer()),
                                icon: Icon(
                                  state.isTimerPaused
                                      ? Icons.play_arrow
                                      : Icons.pause,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final shouldExit =
                                  await _showExitConfirmation(context);
                              if (shouldExit && context.mounted) {
                                context.pop();
                              }
                            },
                            icon: const Icon(Icons.close, color: Colors.white),
                            tooltip: 'Exit',
                          ),
                          const SizedBox(width: 32),
                          IconButton(
                            onPressed: () => context.read<ScoreboardBloc>().add(
                                  UndoLastAction(),
                                ),
                            icon: const Icon(Icons.undo, color: Colors.white),
                            tooltip: 'Undo',
                          ),
                          const SizedBox(width: 32),
                          IconButton(
                            onPressed: () => _showResetConfirmation(context),
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                            tooltip: 'Reset',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Set History Indicator
                  if (state.historySets.isNotEmpty)
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: state.historySets.map((set) {
                          return Text(
                            '${set.scoreA} - ${set.scoreB}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  if (state.isSaving)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScorePanel(
    BuildContext context, {
    required String label,
    required int score,
    required String playerNames,
    required Color color,
    required VoidCallback onTap,
    required VoidCallback onDecrement,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$score',
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 140,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              playerNames,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Decrement Button at the bottom, far from score
            Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove),
                color: Colors.white54,
                tooltip: 'Koreksi Skor (-1)',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeUpDialog(BuildContext context, ScoreboardState state) {
    if (!state.isTimerPaused) {
      context.read<ScoreboardBloc>().add(ToggleTimer());
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Sesi Telah Habis!',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Waktu pertandingan telah mencapai batas durasi. Silakan simpan hasil pertandingan.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showFinishDialog(context, state);
            },
            child: const Text('Lihat Hasil'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('Keluar dari Scoreboard?',
                style: TextStyle(color: Colors.white)),
            content: const Text(
                'Data pertandingan saat ini akan hilang jika Anda keluar sekarang.',
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Keluar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Reset Scoreboard?',
            style: TextStyle(color: Colors.white)),
        content: const Text('Semua skor dan riwayat set akan dikosongkan.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<ScoreboardBloc>().add(ResetMatch());
              setState(() {
                _secondsElapsed = 0;
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showFinishDialog(BuildContext context, ScoreboardState state) {
    final bloc = context.read<ScoreboardBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Match Finished!',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Winner: ${state.winner == 'Team A' ? widget.teamAName : widget.teamBName}',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Final Score:', style: const TextStyle(color: Colors.white70)),
            ...state.historySets.map(
              (s) => Text(
                '${s.scoreA} - ${s.scoreB}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: ${_formatDuration(_secondsElapsed)}',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.pop();
            },
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () {
              bloc.add(
                SaveMatchRequested(
                  bookingId: widget.bookingId,
                  sportType: widget.sportType,
                  players: widget.players,
                  teamAIds: widget.teamA,
                  teamBIds: widget.teamB,
                  teamAName: widget.teamAName,
                  teamBName: widget.teamBName,
                  playerNames: widget.playerNames,
                  venueName: widget.venueName,
                  courtName: widget.courtName,
                  startTime: widget.startTime,
                  endTime: widget.endTime,
                  durationSeconds: _secondsElapsed,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save Result'),
          ),
        ],
      ),
    );
  }
}