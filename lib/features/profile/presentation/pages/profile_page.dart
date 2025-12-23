import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_event.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_state.dart';
import 'package:gsports/features/auth/domain/entities/user_entity.dart';
import 'package:gsports/features/profile/domain/entities/user_stats.dart';
import 'package:gsports/features/scoreboard/presentation/widgets/match_history_widget.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Profil Saya'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_note),
                onPressed: () => context.push('/edit-profile'),
              ),
            ],
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
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
                        const SizedBox(height: 24),
                        _buildStatsCard(state.stats),
                        const SizedBox(height: 32),
                        MatchHistoryWidget(userId: state.user.uid),
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
            stateUser.tier == 'premium' ? 'Premium Member' : 'Free Member',

            style: TextStyle(
              color: stateUser.tier == 'premium' ? Colors.amber[900] : null,

              fontWeight: FontWeight.bold,
            ),
          ),

          backgroundColor: stateUser.tier == 'premium'
              ? Colors.amber[50]
              : Colors.white,

          side: BorderSide(
            color: stateUser.tier == 'premium'
                ? Colors.amber.shade300
                : Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(UserStats stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),

            blurRadius: 10,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          _buildStatItem('Matches', '${stats.matchesPlayed}', Icons.sports),

          _buildStatItem('Won', '${stats.matchesWon}', Icons.emoji_events),

          _buildStatItem('Win Rate', '${stats.winRate}%', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
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
            leading: const Icon(Icons.security_outlined),
            title: const Text('Privasi & Keamanan'),
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
