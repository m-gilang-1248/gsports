import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'core/config/router.dart';
import 'core/config/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/venue/presentation/bloc/venue_bloc.dart';
import 'injection_container.dart'; // Import the DI setup
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  configureDependencies(); // Call the DI setup

  await initializeDateFormatting('id_ID', null);

  runApp(const GsportsApp());
}

class GsportsApp extends StatelessWidget {
  const GsportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => GetIt.I<AuthBloc>()),
        BlocProvider<VenueBloc>(create: (context) => GetIt.I<VenueBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Gsports',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
