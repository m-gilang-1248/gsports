import 'package:flutter/material.dart';

class AppConstants {
  static IconData getSportIcon(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'badminton':
        return Icons.sports_tennis;
      case 'futsal':
      case 'soccer':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'volleyball':
        return Icons.sports_volleyball;
      case 'golf':
        return Icons.sports_golf;
      case 'tennis':
        return Icons.sports_tennis; // Using same icon as badminton for now if dedicated not available, or specific one
      default:
        return Icons.sports;
    }
  }
}
