import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/auth/domain/entities/user_entity.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_event.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_state.dart';
import 'package:gsports/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:gsports/features/profile/presentation/bloc/profile_event.dart';
import 'package:gsports/features/profile/presentation/bloc/profile_state.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous is! AuthUnauthenticated && current is AuthUnauthenticated,
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: BlocProvider(
        create: (context) => GetIt.I<ProfileBloc>()..add(FetchProfile()),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileBloc>().add(FetchProfile());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      _buildHeader(state.user),
                      const SizedBox(height: 32),
                      _buildMenu(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            } else if (state is ProfileError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(UserEntity stateUser) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: stateUser.photoUrl != null
              ? NetworkImage(stateUser.photoUrl!)
              : null,
          child: stateUser.photoUrl == null
              ? Text(
                  stateUser.displayName.isNotEmpty
                      ? stateUser.displayName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          stateUser.displayName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          stateUser.email,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Chip(
          label: Text(
            'Mitra Gsports',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/edit-profile'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Pengaturan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Bantuan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
    );
  }
}
