import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/partner/venue_management/domain/usecases/manage_courts_usecases.dart';

// Events
abstract class CourtManagementEvent {}

class FetchCourts extends CourtManagementEvent {
  final String venueId;
  FetchCourts(this.venueId);
}

class AddCourtRequested extends CourtManagementEvent {
  final String venueId;
  final Court court;
  final List<File> images;
  AddCourtRequested(this.venueId, this.court, this.images);
}

class UpdateCourtRequested extends CourtManagementEvent {
  final String venueId;
  final Court court;
  final List<File>? newImages;
  final List<String>? removedImageUrls;
  UpdateCourtRequested(
    this.venueId,
    this.court, {
    this.newImages,
    this.removedImageUrls,
  });
}

class DeleteCourtRequested extends CourtManagementEvent {
  final String venueId;
  final String courtId;
  DeleteCourtRequested(this.venueId, this.courtId);
}

// States
abstract class CourtManagementState {}

class CourtManagementInitial extends CourtManagementState {}

class CourtManagementLoading extends CourtManagementState {}

class CourtManagementLoaded extends CourtManagementState {
  final List<Court> courts;
  CourtManagementLoaded(this.courts);
}

class CourtManagementError extends CourtManagementState {
  final String message;
  CourtManagementError(this.message);
}

class CourtActionSuccess extends CourtManagementState {
  final String message;
  CourtActionSuccess(this.message);
}

@injectable
class CourtManagementBloc
    extends Bloc<CourtManagementEvent, CourtManagementState> {
  final GetManagedVenueCourts getCourts;
  final AddCourt addCourt;
  final UpdateCourt updateCourt;
  final DeleteCourt deleteCourt;

  CourtManagementBloc(
    this.getCourts,
    this.addCourt,
    this.updateCourt,
    this.deleteCourt,
  ) : super(CourtManagementInitial()) {
    on<FetchCourts>(_onFetchCourts);
    on<AddCourtRequested>(_onAddCourt);
    on<UpdateCourtRequested>(_onUpdateCourt);
    on<DeleteCourtRequested>(_onDeleteCourt);
  }

  Future<void> _onFetchCourts(
    FetchCourts event,
    Emitter<CourtManagementState> emit,
  ) async {
    emit(CourtManagementLoading());
    final result = await getCourts(event.venueId);
    result.fold(
      (failure) => emit(CourtManagementError(failure.message)),
      (courts) => emit(CourtManagementLoaded(courts)),
    );
  }

  Future<void> _onAddCourt(
    AddCourtRequested event,
    Emitter<CourtManagementState> emit,
  ) async {
    emit(CourtManagementLoading());
    final result = await addCourt(
      AddCourtParams(event.venueId, event.court, event.images),
    );
    result.fold((failure) => emit(CourtManagementError(failure.message)), (_) {
      emit(CourtActionSuccess("Court added successfully"));
      add(FetchCourts(event.venueId));
    });
  }

  Future<void> _onUpdateCourt(
    UpdateCourtRequested event,
    Emitter<CourtManagementState> emit,
  ) async {
    emit(CourtManagementLoading());
    final result = await updateCourt(
      UpdateCourtParams(
        event.venueId,
        event.court,
        newImages: event.newImages,
        removedImageUrls: event.removedImageUrls,
      ),
    );
    result.fold((failure) => emit(CourtManagementError(failure.message)), (_) {
      emit(CourtActionSuccess("Court updated successfully"));
      add(FetchCourts(event.venueId));
    });
  }

  Future<void> _onDeleteCourt(
    DeleteCourtRequested event,
    Emitter<CourtManagementState> emit,
  ) async {
    emit(CourtManagementLoading());
    final result = await deleteCourt(
      DeleteCourtParams(event.venueId, event.courtId),
    );
    result.fold((failure) => emit(CourtManagementError(failure.message)), (_) {
      emit(CourtActionSuccess("Court deleted successfully"));
      add(FetchCourts(event.venueId));
    });
  }
}
