import 'package:flutter/material.dart';
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';

class ScoreboardSetupDialog extends StatefulWidget {
  final List<PaymentParticipant> participants;

  const ScoreboardSetupDialog({super.key, required this.participants});

  @override
  State<ScoreboardSetupDialog> createState() => _ScoreboardSetupDialogState();
}

class _ScoreboardSetupDialogState extends State<ScoreboardSetupDialog> {
  final List<String> _teamA = [];
  final List<String> _teamB = [];

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
      title: const Text('Pilih Tim'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Siapa yang bermain?'),
            const SizedBox(height: 16),
            ...widget.participants.map((p) {
              if (p.uid == null) return const SizedBox.shrink();
              final uid = p.uid!;
              final isTeamA = _teamA.contains(uid);
              final isTeamB = _teamB.contains(uid);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(p.name)),
                    ChoiceChip(
                      label: const Text('A'),
                      selected: isTeamA,
                      onSelected: (_) => _toggleSelection(uid, true),
                      selectedColor: Colors.cyanAccent.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('B'),
                      selected: isTeamB,
                      onSelected: (_) => _toggleSelection(uid, false),
                      selectedColor: Colors.deepOrangeAccent.withValues(
                        alpha: 0.3,
                      ),
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
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: (_teamA.isNotEmpty && _teamB.isNotEmpty)
              ? () {
                  Navigator.pop(context, {'teamA': _teamA, 'teamB': _teamB});
                }
              : null,
          child: const Text('Mulai'),
        ),
      ],
    );
  }
}
