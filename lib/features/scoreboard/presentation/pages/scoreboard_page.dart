import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsports/features/scoreboard/presentation/bloc/scoreboard_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:go_router/go_router.dart';

class ScoreboardPage extends StatelessWidget {
  final String bookingId;
  final String sportType;

  const ScoreboardPage({
    super.key,
    required this.bookingId,
    required this.sportType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<ScoreboardBloc>(),
      child: _ScoreboardView(bookingId: bookingId, sportType: sportType),
    );
  }
}

class _ScoreboardView extends StatefulWidget {
  final String bookingId;
  final String sportType;

  const _ScoreboardView({required this.bookingId, required this.sportType});

  @override
  State<_ScoreboardView> createState() => _ScoreboardViewState();
}

class _ScoreboardViewState extends State<_ScoreboardView> {
  @override
  void initState() {
    super.initState();
    // Enable Wakelock to keep screen on
    WakelockPlus.enable();
    // Force Landscape for better experience (optional but recommended for scoreboard)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    // Restore orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<ScoreboardBloc, ScoreboardState>(
        listener: (context, state) {
          if (state.isMatchFinished) {
            _showFinishDialog(context, state);
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
                        label: 'Team A',
                        score: state.scoreA,
                        color: Colors.cyanAccent,
                        onTap: () => context.read<ScoreboardBloc>().add(
                          IncrementScoreA(),
                        ),
                      ),
                    ),
                    // Divider & Info (Center)
                    Container(width: 2, color: Colors.grey[800]),
                    // Team B (Right)
                    Expanded(
                      child: _buildScorePanel(
                        context,
                        label: 'Team B',
                        score: state.scoreB,
                        color: Colors.deepOrangeAccent,
                        onTap: () => context.read<ScoreboardBloc>().add(
                          IncrementScoreB(),
                        ),
                      ),
                    ),
                  ],
                ),

                // Overlay Controls (Center Top/Bottom)
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
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
                          onPressed: () => context.pop(),
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScorePanel(
    BuildContext context, {
    required String label,
    required int score,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
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
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$score',
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 160,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFinishDialog(BuildContext context, ScoreboardState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Match Finished!', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Winner: ${state.winner}',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Final Score:', style: TextStyle(color: Colors.white70)),
            ...state.historySets.map(
              (s) => Text(
                '${s.scoreA} - ${s.scoreB}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Close page
            },
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ScoreboardBloc>().add(
                SaveMatchRequested(
                  bookingId: widget.bookingId,
                  sportType: widget.sportType,
                ),
              );
              Navigator.pop(dialogContext); // Close dialog
              context.pop(); // Close page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Match result saved!')),
              );
            },
            child: const Text('Save Result'),
          ),
        ],
      ),
    );
  }
}
