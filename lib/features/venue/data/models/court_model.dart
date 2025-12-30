import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/court.dart';

part 'court_model.g.dart';

@JsonSerializable()
class CourtModel extends Court {
  const CourtModel({
    required super.id,
    required super.name,
    required super.sportType,
    required super.hourlyPrice,
    super.isActive = true,
    super.surfaceType = 'Standard',
    super.isIndoor = true,
    super.photos = const [],
    super.description = '',
  });

  factory CourtModel.fromJson(Map<String, dynamic> json) =>
      _$CourtModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourtModelToJson(this);

  factory CourtModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourtModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      sportType: data['sportType'] as String? ?? '',
      hourlyPrice: (data['hourlyPrice'] as num? ?? 0).toInt(),
      isActive: data['isActive'] as bool? ?? true,
      surfaceType: data['surfaceType'] as String? ?? 'Standard',
      isIndoor: data['isIndoor'] as bool? ?? true,
      photos: List<String>.from(data['photos'] as List? ?? []),
      description: data['description'] as String? ?? '',
    );
  }
}
