part of 'partner_dashboard_bloc.dart';

abstract class PartnerDashboardState extends Equatable {
  const PartnerDashboardState();

  @override
  List<Object> get props => [];
}

class PartnerDashboardInitial extends PartnerDashboardState {}

class PartnerDashboardLoading extends PartnerDashboardState {}

class PartnerDashboardLoaded extends PartnerDashboardState {
  final PartnerStats stats;

  const PartnerDashboardLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

class PartnerDashboardError extends PartnerDashboardState {
  final String message;

  const PartnerDashboardError(this.message);

  @override
  List<Object> get props => [message];
}
