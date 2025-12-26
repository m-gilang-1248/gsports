part of 'partner_dashboard_bloc.dart';

abstract class PartnerDashboardEvent extends Equatable {
  const PartnerDashboardEvent();

  @override
  List<Object> get props => [];
}

class FetchPartnerDashboardStats extends PartnerDashboardEvent {}
