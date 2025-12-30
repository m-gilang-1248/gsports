import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/features/favorites/domain/usecases/favorites_usecases.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';

// Events
abstract class FavoritesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchFavorites extends FavoritesEvent {
  final String userId;
  FetchFavorites(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ToggleFavoriteRequested extends FavoritesEvent {
  final String userId;
  final Venue venue;
  ToggleFavoriteRequested(this.userId, this.venue);
  @override
  List<Object?> get props => [userId, venue];
}

class CheckIsFavoriteRequested extends FavoritesEvent {
  final String userId;
  final String venueId;
  CheckIsFavoriteRequested(this.userId, this.venueId);
  @override
  List<Object?> get props => [userId, venueId];
}

// States
abstract class FavoritesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Venue> venues;
  FavoritesLoaded(this.venues);
  @override
  List<Object?> get props => [venues];
}

class FavoriteStatusLoaded extends FavoritesState {
  final bool isFavorite;
  FavoriteStatusLoaded(this.isFavorite);
  @override
  List<Object?> get props => [isFavorite];
}

class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoriteVenues getFavoriteVenues;
  final ToggleFavorite toggleFavorite;
  final CheckIsFavorite checkIsFavorite;

  FavoritesBloc({
    required this.getFavoriteVenues,
    required this.toggleFavorite,
    required this.checkIsFavorite,
  }) : super(FavoritesInitial()) {
    on<FetchFavorites>(_onFetchFavorites);
    on<ToggleFavoriteRequested>(_onToggleFavorite);
    on<CheckIsFavoriteRequested>(_onCheckIsFavorite);
  }

  Future<void> _onFetchFavorites(
    FetchFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    final result = await getFavoriteVenues(event.userId);
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (venues) => emit(FavoritesLoaded(venues)),
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await toggleFavorite(
      ToggleFavoriteParams(event.userId, event.venue),
    );
    result.fold((failure) => emit(FavoritesError(failure.message)), (_) {
      // After toggle, re-check status if we were in a status state
      add(CheckIsFavoriteRequested(event.userId, event.venue.id));
    });
  }

  Future<void> _onCheckIsFavorite(
    CheckIsFavoriteRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await checkIsFavorite(
      CheckIsFavoriteParams(event.userId, event.venueId),
    );
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (isFav) => emit(FavoriteStatusLoaded(isFav)),
    );
  }
}
