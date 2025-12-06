// ignore_for_file: invalid_annotation_target
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment_info.dart';

part 'payment_info_model.g.dart';

@JsonSerializable()
class PaymentInfoModel extends PaymentInfo {
  const PaymentInfoModel({
    required super.token,
    @JsonKey(name: 'redirect_url') required super.redirectUrl,
  });

  factory PaymentInfoModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentInfoModelToJson(this);
}
