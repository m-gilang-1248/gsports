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
import 'package:injectable/injectable.dart' as _i526;

import 'core/injection_modules/firebase_module.dart' as _i896;
import 'features/auth/data/datasources/auth_remote_data_source.dart' as _i767;
import 'features/auth/data/repositories/auth_repository_impl.dart' as _i111;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/usecases/check_auth_status.dart' as _i818;
import 'features/auth/domain/usecases/login_user.dart' as _i1073;
import 'features/auth/domain/usecases/logout_user.dart' as _i657;
import 'features/auth/domain/usecases/register_user.dart' as _i14;
import 'features/auth/presentation/bloc/auth_bloc.dart' as _i363;
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
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => firebaseModule.firebaseFirestore,
    );
    gh.lazySingleton<_i1039.VenueRemoteDataSource>(
      () => _i1039.VenueRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i767.AuthRemoteDataSource>(
      () => _i767.AuthRemoteDataSourceImpl(
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        firebaseFirestore: gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.factory<_i997.VenueRepository>(
      () => _i346.VenueRepositoryImpl(gh<_i1039.VenueRemoteDataSource>()),
    );
    gh.factory<_i1015.AuthRepository>(
      () => _i111.AuthRepositoryImpl(
        remoteDataSource: gh<_i767.AuthRemoteDataSource>(),
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
    gh.factory<_i363.AuthBloc>(
      () => _i363.AuthBloc(
        gh<_i818.CheckAuthStatus>(),
        gh<_i1073.LoginUser>(),
        gh<_i14.RegisterUser>(),
        gh<_i657.LogoutUser>(),
      ),
    );
    return this;
  }
}

class _$FirebaseModule extends _i896.FirebaseModule {}
