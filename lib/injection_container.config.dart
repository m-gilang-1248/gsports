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
import 'package:get_it/get_it.dart' as _i174;
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
import 'features/auth/presentation/bloc/auth_bloc.dart' as _i363;
import 'features/booking/data/datasources/booking_remote_data_source.dart'
    as _i97;
import 'features/booking/data/repositories/booking_repository_impl.dart'
    as _i703;
import 'features/booking/domain/repositories/booking_repository.dart' as _i829;
import 'features/booking/domain/usecases/check_availability.dart' as _i549;
import 'features/booking/domain/usecases/create_booking.dart' as _i46;
import 'features/booking/domain/usecases/cancel_booking.dart' as _i99;
import 'features/booking/domain/usecases/update_booking_status.dart' as _i100;
import 'features/booking/presentation/bloc/booking_bloc.dart' as _i393;
import 'features/payment/data/datasources/payment_remote_data_source.dart'
    as _i692;
import 'features/payment/data/repositories/payment_repository_impl.dart'
    as _i210;
import 'features/payment/domain/repositories/payment_repository.dart' as _i376;
import 'features/payment/domain/usecases/create_invoice.dart' as _i206;
import 'features/payment/domain/usecases/get_transaction_status.dart' as _i207;
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
    gh.lazySingleton<_i519.Client>(() => networkModule.httpClient);
    gh.lazySingleton<_i1039.VenueRemoteDataSource>(
      () => _i1039.VenueRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i767.AuthRemoteDataSource>(
      () => _i767.AuthRemoteDataSourceImpl(
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        firebaseFirestore: gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i97.BookingRemoteDataSource>(
      () => _i97.BookingRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i997.VenueRepository>(
      () => _i346.VenueRepositoryImpl(gh<_i1039.VenueRemoteDataSource>()),
    );
    gh.factory<_i829.BookingRepository>(
      () => _i703.BookingRepositoryImpl(gh<_i97.BookingRemoteDataSource>()),
    );
    gh.lazySingleton<_i692.PaymentRemoteDataSource>(
      () => _i692.PaymentRemoteDataSourceImpl(gh<_i519.Client>()),
    );
    gh.factory<_i1015.AuthRepository>(
      () => _i111.AuthRepositoryImpl(
        remoteDataSource: gh<_i767.AuthRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i549.CheckAvailability>(
      () => _i549.CheckAvailability(gh<_i829.BookingRepository>()),
    );
    gh.lazySingleton<_i46.CreateBooking>(
      () => _i46.CreateBooking(gh<_i829.BookingRepository>()),
    );
    gh.lazySingleton<_i99.CancelBooking>(
      () => _i99.CancelBooking(gh<_i829.BookingRepository>()),
    );
    gh.lazySingleton<_i100.UpdateBookingStatus>(
      () => _i100.UpdateBookingStatus(gh<_i829.BookingRepository>()),
    );
    gh.factory<_i393.BookingBloc>(
      () => _i393.BookingBloc(
        checkAvailability: gh<_i549.CheckAvailability>(),
        createBooking: gh<_i46.CreateBooking>(),
        createInvoice: gh<_i206.CreateInvoice>(),
        cancelBooking: gh<_i99.CancelBooking>(),
        updateBookingStatus: gh<_i100.UpdateBookingStatus>(),
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
    gh.lazySingleton<_i376.PaymentRepository>(
      () => _i210.PaymentRepositoryImpl(gh<_i692.PaymentRemoteDataSource>()),
    );
    gh.factory<_i363.AuthBloc>(
      () => _i363.AuthBloc(
        gh<_i818.CheckAuthStatus>(),
        gh<_i1073.LoginUser>(),
        gh<_i14.RegisterUser>(),
        gh<_i657.LogoutUser>(),
      ),
    );
    gh.lazySingleton<_i206.CreateInvoice>(
      () => _i206.CreateInvoice(gh<_i376.PaymentRepository>()),
    );
    gh.lazySingleton<_i207.GetTransactionStatus>(
      () => _i207.GetTransactionStatus(gh<_i376.PaymentRepository>()),
    );
    return this;
  }
}

class _$FirebaseModule extends _i896.FirebaseModule {}

class _$NetworkModule extends _i559.NetworkModule {}
