import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gsports/features/partner/dashboard/domain/entities/partner_stats.dart';
import 'package:gsports/features/partner/dashboard/domain/usecases/get_partner_stats.dart';

part 'partner_dashboard_event.dart';
part 'partner_dashboard_state.dart';

@injectable
class PartnerDashboardBloc extends Bloc<PartnerDashboardEvent, PartnerDashboardState> {
  final GetPartnerStats getPartnerStats;
  final FirebaseAuth firebaseAuth;

  PartnerDashboardBloc(this.getPartnerStats, this.firebaseAuth)
      : super(PartnerDashboardInitial()) {
    on<FetchPartnerDashboardStats>(_onFetchStats);
  }

  Future<void> _onFetchStats(
    FetchPartnerDashboardStats event,
    Emitter<PartnerDashboardState> emit,
  ) async {
    emit(PartnerDashboardLoading());

    final user = firebaseAuth.currentUser;
    if (user == null) {
      emit(const PartnerDashboardError("User not logged in"));
      return;
    }

    final result = await getPartnerStats(user.uid);

    result.fold(
      (failure) => emit(PartnerDashboardError(failure.message)),
      (stats) => emit(PartnerDashboardLoaded(stats)),
    );
  }
}
