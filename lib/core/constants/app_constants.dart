import 'package:flutter/material.dart';

class SportCategory {
  final String id;
  final String displayName;
  final IconData icon;
  final List<String> keywords;

  const SportCategory({
    required this.id,
    required this.displayName,
    required this.icon,
    this.keywords = const [],
  });
}

class AppConstants {
  static const List<SportCategory> sports = [
    SportCategory(
      id: 'badminton',
      displayName: 'Badminton',
      icon: Icons.sports_tennis,
      keywords: ['bulutangkis', 'bulu tangkis', 'raket'],
    ),
    SportCategory(
      id: 'futsal',
      displayName: 'Futsal',
      icon: Icons.sports_soccer,
      keywords: ['bola', 'soccer'],
    ),
    SportCategory(
      id: 'mini_soccer',
      displayName: 'Mini Soccer',
      icon: Icons.sports_soccer,
      keywords: ['mini soccer', 'bola'],
    ),
    SportCategory(
      id: 'football',
      displayName: 'Sepak Bola',
      icon: Icons.sports_soccer,
      keywords: ['bola', 'soccer', 'sepakbola'],
    ),
    SportCategory(
      id: 'basketball',
      displayName: 'Basket',
      icon: Icons.sports_basketball,
      keywords: ['basket', 'hoop'],
    ),
    SportCategory(
      id: 'tennis',
      displayName: 'Tenis',
      icon: Icons.sports_tennis,
      keywords: ['tennis', 'raket'],
    ),
    SportCategory(
      id: 'table_tennis',
      displayName: 'Tenis Meja',
      icon: Icons.sports_tennis,
      keywords: ['pingpong', 'ping pong', 'meja'],
    ),
    SportCategory(
      id: 'golf',
      displayName: 'Golf',
      icon: Icons.golf_course,
      keywords: ['golf', 'course'],
    ),
    SportCategory(
      id: 'billiard',
      displayName: 'Billiard',
      icon: Icons.bubble_chart,
      keywords: ['biliar', 'bola sodok', 'pool'],
    ),
    SportCategory(
      id: 'padel',
      displayName: 'Padel',
      icon: Icons.sports_tennis,
      keywords: ['padel', 'raket'],
    ),
    SportCategory(
      id: 'volleyball',
      displayName: 'Voli',
      icon: Icons.sports_volleyball,
      keywords: ['voli', 'spike'],
    ),
    SportCategory(
      id: 'gym',
      displayName: 'Gym',
      icon: Icons.fitness_center,
      keywords: ['fitness', 'olahraga', 'sehat'],
    ),
    SportCategory(
      id: 'swimming',
      displayName: 'Renang',
      icon: Icons.pool,
      keywords: ['kolam', 'berenang', 'water'],
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
