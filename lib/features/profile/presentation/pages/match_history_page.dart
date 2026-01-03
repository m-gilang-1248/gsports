import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gsports/features/scoreboard/presentation/widgets/match_history_widget.dart';

class MatchHistoryPage extends StatelessWidget {
  const MatchHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Pertandingan')),
        body: const Center(child: Text('Silakan login untuk melihat riwayat.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pertandingan')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MatchHistoryWidget(userId: user.uid),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
