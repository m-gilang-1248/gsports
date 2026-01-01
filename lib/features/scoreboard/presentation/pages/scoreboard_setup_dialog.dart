import 'package:flutter/material.dart';
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_configuration.dart';
import 'package:gsports/core/config/app_colors.dart';

class ScoreboardSetupDialog extends StatefulWidget {
  final List<PaymentParticipant> participants;
  final String sportType;

  const ScoreboardSetupDialog({
    super.key,
    required this.participants,
    required this.sportType,
  });

  @override
  State<ScoreboardSetupDialog> createState() => _ScoreboardSetupDialogState();
}

class _ScoreboardSetupDialogState extends State<ScoreboardSetupDialog> {
  final List<String> _teamA = [];
  final List<String> _teamB = [];
  final _teamAController = TextEditingController(text: 'Team A');
  final _teamBController = TextEditingController(text: 'Team B');

  // Config controllers
  late MatchConfiguration _config;
  late TextEditingController _durationController;
  late TextEditingController _periodsController;
  late TextEditingController _pointsController;
  late TextEditingController _setsNeededController;

  @override
  void initState() {
    super.initState();
    _config = MatchConfiguration.forSport(widget.sportType);

    _durationController = TextEditingController(
      text: (_config.durationPerPeriodSeconds ~/ 60).toString(),
    );
    _periodsController = TextEditingController(
      text: _config.numberOfPeriods.toString(),
    );
    _pointsController = TextEditingController(
      text: _config.winningScorePerSet.toString(),
    );
    _setsNeededController = TextEditingController(
      text: _config.winningSetsNeeded.toString(),
    );
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _durationController.dispose();
    _periodsController.dispose();
    _pointsController.dispose();
    _setsNeededController.dispose();
    super.dispose();
  }

  void _toggleSelection(String uid, bool isTeamA) {
    setState(() {
      if (isTeamA) {
        if (_teamA.contains(uid)) {
          _teamA.remove(uid);
        } else {
          _teamA.add(uid);
          _teamB.remove(uid); // Remove from Team B if selected
        }
      } else {
        if (_teamB.contains(uid)) {
          _teamB.remove(uid);
        } else {
          _teamB.add(uid);
          _teamA.remove(uid); // Remove from Team A if selected
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Match Setup',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRulesSection(),
            const SizedBox(height: 24),
            Text(
              'Team Names',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _teamAController,
              label: 'Team A Name',
              icon: Icons.shield_outlined,
              color: Colors.cyan,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _teamBController,
              label: 'Team B Name',
              icon: Icons.shield_outlined,
              color: Colors.deepOrange,
            ),
            const SizedBox(height: 24),
            Text(
              'Who is playing?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            if (widget.participants.isEmpty)
              const Text(
                'No participants available.',
                style: TextStyle(color: Colors.grey),
              ),
            ...widget.participants.map((p) {
              if (p.uid == null) return const SizedBox.shrink();
              final uid = p.uid!;
              final isTeamA = _teamA.contains(uid);
              final isTeamB = _teamB.contains(uid);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    _buildSelectionChip(
                      'A',
                      isTeamA,
                      Colors.cyan,
                      () => _toggleSelection(uid, true),
                    ),
                    const SizedBox(width: 8),
                    _buildSelectionChip(
                      'B',
                      isTeamB,
                      Colors.deepOrange,
                      () => _toggleSelection(uid, false),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: (_teamA.isNotEmpty && _teamB.isNotEmpty)
              ? () {
                  // Reconstruct config from inputs
                  final duration = int.tryParse(_durationController.text) ?? 0;
                  final periods = int.tryParse(_periodsController.text) ?? 1;
                  final points = int.tryParse(_pointsController.text) ?? 21;
                  final sets = int.tryParse(_setsNeededController.text) ?? 2;

                  final finalConfig = _config.copyWith(
                    durationPerPeriodSeconds: duration * 60,
                    numberOfPeriods: periods,
                    winningScorePerSet: points,
                    winningSetsNeeded: sets,
                  );

                  Navigator.pop(context, {
                    'teamA': _teamA,
                    'teamB': _teamB,
                    'teamAName': _teamAController.text.isEmpty
                        ? 'Team A'
                        : _teamAController.text,
                    'teamBName': _teamBController.text.isEmpty
                        ? 'Team B'
                        : _teamBController.text,
                    'config': finalConfig,
                  });
                }
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Start Match'),
        ),
      ],
    );
  }

  Widget _buildRulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rules (${_config.scoringType == ScoringType.timeBased ? "Time" : "Points"})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            // Could add toggle here if we want to switch modes entirely
          ],
        ),
        const SizedBox(height: 12),
        if (_config.scoringType == ScoringType.timeBased) ...[
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _durationController,
                  label: 'Mins / Period',
                  icon: Icons.timer,
                  color: Colors.blue,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _periodsController,
                  label: 'Periods',
                  icon: Icons.repeat,
                  color: Colors.blue,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _pointsController,
                  label: 'Points / Set',
                  icon: Icons.numbers,
                  color: Colors.green,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _setsNeededController,
                  label: 'Sets to Win',
                  icon: Icons.emoji_events_outlined,
                  color: Colors.green,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
        prefixIcon: Icon(icon, color: color, size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSelectionChip(
    String label,
    bool isSelected,
    MaterialColor color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
