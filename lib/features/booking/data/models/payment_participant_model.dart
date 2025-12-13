import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment_participant.dart';

part 'payment_participant_model.g.dart';

@JsonSerializable()
class PaymentParticipantModel extends PaymentParticipant {
  const PaymentParticipantModel({
    super.uid,
    required super.name,
    required super.status,
    required super.paymentStatusToHost,
    super.profileUrl,
  });

  factory PaymentParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentParticipantModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentParticipantModelToJson(this);

  factory PaymentParticipantModel.fromEntity(PaymentParticipant entity) {
    return PaymentParticipantModel(
      uid: entity.uid,
      name: entity.name,
      status: entity.status,
      paymentStatusToHost: entity.paymentStatusToHost,
      profileUrl: entity.profileUrl,
    );
  }

  PaymentParticipantModel copyWith({
    String? uid,
    String? name,
    String? status,
    String? paymentStatusToHost,
    String? profileUrl,
  }) {
    return PaymentParticipantModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      status: status ?? this.status,
      paymentStatusToHost: paymentStatusToHost ?? this.paymentStatusToHost,
      profileUrl: profileUrl ?? this.profileUrl,
    );
  }
}
