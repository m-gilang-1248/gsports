import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/features/auth/domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_user_stats.dart';
import '../../domain/usecases/update_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository authRepository;
  final GetUserStats getUserStats;
  final UpdateProfile updateProfile;

  ProfileBloc({
    required this.authRepository,
    required this.getUserStats,
    required this.updateProfile,
  }) : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  Future<void> _onFetchProfile(
    FetchProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final userResult = await authRepository.checkAuthStatus();

    await userResult.fold(
      (failure) async => emit(ProfileError(failure.message)),
      (user) async {
        final statsResult = await getUserStats(user.uid);
        statsResult.fold(
          (failure) => emit(ProfileError(failure.message)),
          (stats) => emit(ProfileLoaded(user: user, stats: stats)),
        );
      },
    );
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state; // Capture current state (stats)
    final userResult = await authRepository.checkAuthStatus();

    await userResult.fold(
      (failure) async => emit(ProfileError(failure.message)),
      (user) async {
        emit(ProfileUpdating());

        final updateResult = await updateProfile(
          UpdateProfileParams(
            uid: user.uid,
            displayName: event.displayName,
            phoneNumber: event.phoneNumber,
            imageFile: event.imageFile,
          ),
        );

        updateResult.fold((failure) => emit(ProfileError(failure.message)), (
          updatedUser,
        ) {
          emit(ProfileUpdateSuccess(updatedUser));
          // Restore Loaded state with updated user and existing stats
          if (currentState is ProfileLoaded) {
            emit(ProfileLoaded(user: updatedUser, stats: (currentState).stats));
          } else {
            // Should not happen, but re-fetch if needed
            add(FetchProfile());
          }
        });
      },
    );
  }
}
