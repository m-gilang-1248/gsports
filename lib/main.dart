import 'package:flutter/material.dart';
import 'core/config/router.dart';
import 'core/config/theme.dart';
import 'injection_container.dart';
// import 'firebase_options.dart'; // Uncomment after generating options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await dotenv.load(fileName: ".env"); // Uncomment when .env is present

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // ); // Uncomment after generating options and importing

  // Temporary Firebase init for development without options (or use CLI to generate)
  // await Firebase.initializeApp();

  configureDependencies();

  runApp(const GsportsApp());
}

class GsportsApp extends StatelessWidget {
  const GsportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gsports',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
