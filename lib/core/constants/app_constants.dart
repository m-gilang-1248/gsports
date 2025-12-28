import 'package:flutter/material.dart';

class SportCategory {
  final String id;
  final String displayName;
  final IconData icon;

  const SportCategory({
    required this.id,
    required this.displayName,
    required this.icon,
  });
}

class AppConstants {
  static const List<SportCategory> sports = [
    SportCategory(
      id: 'badminton',
      displayName: 'Badminton',
      icon: Icons.sports_tennis,
    ),
    SportCategory(
      id: 'futsal',
      displayName: 'Futsal',
      icon: Icons.sports_soccer,
    ),
    SportCategory(
      id: 'mini_soccer',
      displayName: 'Mini Soccer',
      icon: Icons.sports_soccer,
    ),
    SportCategory(
      id: 'football',
      displayName: 'Sepak Bola',
      icon: Icons.sports_soccer,
    ),
    SportCategory(
      id: 'basketball',
      displayName: 'Basket',
      icon: Icons.sports_basketball,
    ),
    SportCategory(
      id: 'tennis',
      displayName: 'Tenis',
      icon: Icons.sports_tennis,
    ),
    SportCategory(
      id: 'table_tennis',
      displayName: 'Tenis Meja',
      icon: Icons.sports_tennis,
    ),
    SportCategory(
      id: 'golf',
      displayName: 'Golf',
      icon: Icons.golf_course,
    ),
    SportCategory(
      id: 'billiard',
      displayName: 'Billiard',
      icon: Icons.bubble_chart, // Visual proxy for racked balls
    ),
    SportCategory(
      id: 'padel',
      displayName: 'Padel',
      icon: Icons.sports_tennis,
    ),
    SportCategory(
      id: 'volleyball',
      displayName: 'Voli',
      icon: Icons.sports_volleyball,
    ),
    SportCategory(
      id: 'gym',
      displayName: 'Gym',
      icon: Icons.fitness_center,
    ),
    SportCategory(
      id: 'swimming',
      displayName: 'Renang',
      icon: Icons.pool,
    ),
  ];

  static IconData getSportIcon(String sportType) {
    try {
      return sports
          .firstWhere(
            (s) => s.id.toLowerCase() == sportType.toLowerCase(),
            orElse:
                () => const SportCategory(
                  id: 'unknown',
                  displayName: 'Unknown',
                  icon: Icons.sports,
                ),
          )
          .icon;
    } catch (e) {
      return Icons.sports;
    }
  }

  static String getSportName(String sportType) {
    try {
      return sports
          .firstWhere(
            (s) => s.id.toLowerCase() == sportType.toLowerCase(),
            orElse:
                () => SportCategory(
                  id: sportType,
                  displayName: sportType, // Fallback to key
                  icon: Icons.sports,
                ),
          )
          .displayName;
    } catch (e) {
      return sportType;
    }
  }
}
