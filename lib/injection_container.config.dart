// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;

import 'core/injection_modules/firebase_module.dart' as _i896;
import 'core/injection_modules/network_module.dart' as _i559;
import 'features/auth/data/datasources/auth_remote_data_source.dart' as _i767;
import 'features/auth/data/repositories/auth_repository_impl.dart' as _i111;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/usecases/check_auth_status.dart' as _i818;
import 'features/auth/domain/usecases/login_user.dart' as _i1073;
import 'features/auth/domain/usecases/logout_user.dart' as _i657;
import 'features/auth/domain/usecases/register_user.dart' as _i14;
import 'features/auth/domain/usecases/sign_in_with_google.dart' as _i648;
import 'features/auth/presentation/bloc/auth_bloc.dart' as _i363;
import 'features/booking/data/datasources/booking_remote_data_source.dart'
    as _i97;
import 'features/booking/data/repositories/booking_repository_impl.dart'
    as _i703;
import 'features/booking/domain/repositories/booking_repository.dart' as _i829;
import 'features/booking/domain/usecases/cancel_booking.dart' as _i488;
import 'features/booking/domain/usecases/check_availability.dart' as _i549;
import 'features/booking/domain/usecases/create_booking.dart' as _i46;
import 'features/booking/domain/usecases/generate_split_code.dart' as _i698;
import 'features/booking/domain/usecases/get_booking_detail.dart' as _i548;
import 'features/booking/domain/usecases/get_my_bookings.dart' as _i776;
import 'features/booking/domain/usecases/join_booking.dart' as _i1015;
import 'features/booking/domain/usecases/update_booking_status.dart' as _i781;
import 'features/booking/domain/usecases/update_participant_status.dart'
    as _i416;
import 'features/booking/domain/usecases/update_payment_info.dart' as _i486;
import 'features/booking/presentation/bloc/booking_bloc.dart' as _i393;
import 'features/booking/presentation/bloc/detail/booking_detail_bloc.dart'
    as _i176;
import 'features/booking/presentation/bloc/history/history_bloc.dart' as _i1064;
import 'features/payment/data/datasources/payment_remote_data_source.dart'
    as _i692;
import 'features/payment/data/repositories/payment_repository_impl.dart'
    as _i210;
import 'features/payment/domain/repositories/payment_repository.dart' as _i376;
import 'features/payment/domain/usecases/create_invoice.dart' as _i206;
import 'features/payment/domain/usecases/get_transaction_status.dart' as _i326;
import 'features/profile/data/datasources/profile_remote_data_source.dart'
    as _i336;
import 'features/profile/data/datasources/profile_remote_data_source_impl.dart'
    as _i864;
import 'features/profile/data/repositories/profile_repository_impl.dart'
    as _i277;
import 'features/profile/domain/repositories/profile_repository.dart' as _i626;
import 'features/profile/domain/usecases/get_user_stats.dart' as _i810;
import 'features/profile/domain/usecases/update_profile.dart' as _i759;
import 'features/profile/presentation/bloc/profile_bloc.dart' as _i284;
import 'features/scoreboard/data/datasources/scoreboard_remote_data_source.dart'
    as _i104;
import 'features/scoreboard/data/repositories/scoreboard_repository_impl.dart'
    as _i107;
import 'features/scoreboard/domain/repositories/scoreboard_repository.dart'
    as _i556;
import 'features/scoreboard/presentation/bloc/scoreboard_bloc.dart' as _i780;
import 'features/venue/data/datasources/venue_remote_data_source.dart'
    as _i1039;
import 'features/venue/data/repositories/venue_repository_impl.dart' as _i346;
import 'features/venue/domain/repositories/venue_repository.dart' as _i997;
import 'features/venue/domain/usecases/get_venue_courts.dart' as _i606;
import 'features/venue/domain/usecases/get_venue_detail.dart' as _i15;
import 'features/venue/domain/usecases/get_venues.dart' as _i578;
import 'features/venue/presentation/bloc/venue_bloc.dart' as _i730;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => firebaseModule.firebaseFirestore,
    );
    gh.lazySingleton<_i457.FirebaseStorage>(
      () => firebaseModule.firebaseStorage,
    );
    gh.lazySingleton<_i116.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.lazySingleton<_i519.Client>(() => networkModule.httpClient);
    gh.lazySingleton<_i1039.VenueRemoteDataSource>(
      () => _i1039.VenueRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i97.BookingRemoteDataSource>(
      () => _i97.BookingRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i104.ScoreboardRemoteDataSource>(
      () => _i104.ScoreboardRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i997.VenueRepository>(
      () => _i346.VenueRepositoryImpl(gh<_i1039.VenueRemoteDataSource>()),
    );
    gh.factory<_i829.BookingRepository>(
      () => _i703.BookingRepositoryImpl(gh<_i97.BookingRemoteDataSource>()),
    );
    gh.factory<_i556.ScoreboardRepository>(
      () => _i107.ScoreboardRepositoryImpl(
        gh<_i104.ScoreboardRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i692.PaymentRemoteDataSource>(
      () => _i692.PaymentRemoteDataSourceImpl(gh<_i519.Client>()),
    );
    gh.factory<_i767.AuthRemoteDataSource>(
      () => _i767.AuthRemoteDataSourceImpl(
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        firebaseFirestore: gh<_i974.FirebaseFirestore>(),
        googleSignIn: gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.factory<_i780.ScoreboardBloc>(
      () => _i780.ScoreboardBloc(gh<_i556.ScoreboardRepository>()),
    );
    gh.factory<_i1015.AuthRepository>(
      () => _i111.AuthRepositoryImpl(
        remoteDataSource: gh<_i767.AuthRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i488.CancelBooking>(
      () => _i488.CancelBooking(gh<_i829.BookingRepository>()),
    );
    gh.lazySingleton<_i549.CheckAvailability>(
      () => _i549.CheckAvailability(gh<_i829.BookingRepository>()),
    );
    gh.lazySingleton<_i46.CreateBooking>(
      () => _i46.CreateBooking(gh<_i829.BookingRepository>()),
    );
    gh.lazySingleton<_i776.GetMyBookings>(
      () => _i776.GetMyBookings(gh<_i829.BookingRepository>()),
    );
    gh.lazySingleton<_i781.UpdateBookingStatus>(
      () => _i781.UpdateBookingStatus(gh<_i829.BookingRepository>()),
    );
    gh.lazySingleton<_i416.UpdateParticipantStatus>(
      () => _i416.UpdateParticipantStatus(gh<_i829.BookingRepository>()),
    );
    gh.lazySingleton<_i486.UpdatePaymentInfo>(
      () => _i486.UpdatePaymentInfo(gh<_i829.BookingRepository>()),
    );
    gh.factory<_i698.GenerateSplitCode>(
      () => _i698.GenerateSplitCode(gh<_i829.BookingRepository>()),
    );
    gh.factory<_i548.GetBookingDetail>(
      () => _i548.GetBookingDetail(gh<_i829.BookingRepository>()),
    );
    gh.factory<_i1015.JoinBooking>(
      () => _i1015.JoinBooking(gh<_i829.BookingRepository>()),
    );
    gh.lazySingleton<_i336.ProfileRemoteDataSource>(
      () => _i864.ProfileRemoteDataSourceImpl(
        firestore: gh<_i974.FirebaseFirestore>(),
        storage: gh<_i457.FirebaseStorage>(),
        firebaseAuth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i606.GetVenueCourts>(
      () => _i606.GetVenueCourts(gh<_i997.VenueRepository>()),
    );
    gh.lazySingleton<_i15.GetVenueDetail>(
      () => _i15.GetVenueDetail(gh<_i997.VenueRepository>()),
    );
    gh.lazySingleton<_i578.GetVenues>(
      () => _i578.GetVenues(gh<_i997.VenueRepository>()),
    );
    gh.factory<_i626.ProfileRepository>(
      () => _i277.ProfileRepositoryImpl(gh<_i336.ProfileRemoteDataSource>()),
    );
    gh.factory<_i810.GetUserStats>(
      () => _i810.GetUserStats(gh<_i626.ProfileRepository>()),
    );
    gh.factory<_i759.UpdateProfile>(
      () => _i759.UpdateProfile(gh<_i626.ProfileRepository>()),
    );
    gh.factory<_i648.SignInWithGoogle>(
      () => _i648.SignInWithGoogle(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i818.CheckAuthStatus>(
      () => _i818.CheckAuthStatus(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i1073.LoginUser>(
      () => _i1073.LoginUser(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i657.LogoutUser>(
      () => _i657.LogoutUser(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i14.RegisterUser>(
      () => _i14.RegisterUser(gh<_i1015.AuthRepository>()),
    );
    gh.factory<_i730.VenueBloc>(
      () => _i730.VenueBloc(
        getVenues: gh<_i578.GetVenues>(),
        getVenueDetail: gh<_i15.GetVenueDetail>(),
        getVenueCourts: gh<_i606.GetVenueCourts>(),
      ),
    );
    gh.factory<_i363.AuthBloc>(
      () => _i363.AuthBloc(
        gh<_i818.CheckAuthStatus>(),
        gh<_i1073.LoginUser>(),
        gh<_i14.RegisterUser>(),
        gh<_i657.LogoutUser>(),
        gh<_i648.SignInWithGoogle>(),
      ),
    );
    gh.factory<_i1064.HistoryBloc>(
      () => _i1064.HistoryBloc(
        getMyBookings: gh<_i776.GetMyBookings>(),
        joinBooking: gh<_i1015.JoinBooking>(),
        firebaseAuth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i376.PaymentRepository>(
      () => _i210.PaymentRepositoryImpl(gh<_i692.PaymentRemoteDataSource>()),
    );
    gh.factory<_i284.ProfileBloc>(
      () => _i284.ProfileBloc(
        authRepository: gh<_i1015.AuthRepository>(),
        getUserStats: gh<_i810.GetUserStats>(),
        updateProfile: gh<_i759.UpdateProfile>(),
      ),
    );
    gh.lazySingleton<_i206.CreateInvoice>(
      () => _i206.CreateInvoice(gh<_i376.PaymentRepository>()),
    );
    gh.lazySingleton<_i326.GetTransactionStatus>(
      () => _i326.GetTransactionStatus(gh<_i376.PaymentRepository>()),
    );
    gh.factory<_i176.BookingDetailBloc>(
      () => _i176.BookingDetailBloc(
        gh<_i548.GetBookingDetail>(),
        gh<_i698.GenerateSplitCode>(),
        gh<_i416.UpdateParticipantStatus>(),
        gh<_i488.CancelBooking>(),
        gh<_i326.GetTransactionStatus>(),
        gh<_i781.UpdateBookingStatus>(),
        gh<_i556.ScoreboardRepository>(),
      ),
    );
    gh.factory<_i393.BookingBloc>(
      () => _i393.BookingBloc(
        checkAvailability: gh<_i549.CheckAvailability>(),
        createBooking: gh<_i46.CreateBooking>(),
        createInvoice: gh<_i206.CreateInvoice>(),
        cancelBooking: gh<_i488.CancelBooking>(),
        updateBookingStatus: gh<_i781.UpdateBookingStatus>(),
        getTransactionStatus: gh<_i326.GetTransactionStatus>(),
        updatePaymentInfo: gh<_i486.UpdatePaymentInfo>(),
      ),
    );
    return this;
  }
}

class _$FirebaseModule extends _i896.FirebaseModule {}

class _$NetworkModule extends _i559.NetworkModule {}
