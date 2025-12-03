import 'package:equatable/equatable.dart';

class Court extends Equatable {
  final String id;
  final String name;
  final String sportType;
  final int hourlyPrice;

  const Court({
    required this.id,
    required this.name,
    required this.sportType,
    required this.hourlyPrice,
  });

  @override
  List<Object?> get props => [id, name, sportType, hourlyPrice];
}
