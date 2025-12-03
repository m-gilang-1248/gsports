import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/court.dart';

part 'court_model.g.dart';

@JsonSerializable()
class CourtModel extends Court {
  @override
  final String id;
  @override
  final String name;
  @override
  final String sportType;
  @override
  final int hourlyPrice;

  const CourtModel({
    required this.id,
    required this.name,
    required this.sportType,
    required this.hourlyPrice,
  }) : super(
         id: id,
         name: name,
         sportType: sportType,
         hourlyPrice: hourlyPrice,
       );

  factory CourtModel.fromJson(Map<String, dynamic> json) =>
      _$CourtModelFromJson(json);

  factory CourtModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourtModel(
      id: doc.id,
      name: data['name'] ?? '',
      sportType: data['sportType'] ?? '',
      hourlyPrice: (data['hourlyPrice'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$CourtModelToJson(this);
}
