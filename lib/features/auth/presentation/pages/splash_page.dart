import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Add a delay before checking auth status to show the logo
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.role == 'mitra') {
            context.go('/owner-dashboard');
          } else if (state.user.role == 'admin_platform') {
            context.go('/admin/payouts');
          } else {
            context.go('/home');
          }
        } else if (state is AuthUnauthenticated) {
          context.go('/login');
        } else if (state is AuthFailure) {
          // Optionally show an error message or redirect to login
          context.go('/login');
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder for the App Logo
              Image.asset(
                'assets/logo/gsports_logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'Gsports',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
