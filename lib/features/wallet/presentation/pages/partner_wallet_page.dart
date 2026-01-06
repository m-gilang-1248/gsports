import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_state.dart';
import 'package:gsports/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:gsports/features/profile/presentation/bloc/profile_event.dart';
import 'package:gsports/features/profile/presentation/bloc/profile_state.dart';
import 'package:gsports/injection_container.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class PartnerWalletPage extends StatelessWidget {
  const PartnerWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final authState = context.read<AuthBloc>().state;
            String userId = '';
            if (authState is AuthAuthenticated) {
              userId = authState.user.uid;
            }
            return getIt<WalletBloc>()..add(FetchWalletData(userId));
          },
        ),
        BlocProvider(
          create: (context) => getIt<ProfileBloc>()..add(FetchProfile()),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Dompet Mitra'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        body: const PartnerWalletView(),
      ),
    );
  }
}

class PartnerWalletView extends StatelessWidget {
  const PartnerWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is WalletPayoutSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permintaan penarikan dana berhasil diajukan'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state is WalletError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            context.read<WalletBloc>().add(FetchWalletData(authState.user.uid));
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BALANCE CARD
              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  int balance = 0;
                  if (state is WalletLoaded) {
                    balance = state.balance;
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.success, Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saldo Tersedia',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: balance > 0
                                  ? () {
                                      debugPrint('🔵 Tombol Tarik Dana ditekan. Balance: $balance');
                                      _showWithdrawDialog(context, balance);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.success,
                                disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                                disabledForegroundColor: AppColors.success.withValues(alpha: 0.5),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Tarik Dana',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // TRANSACTION HISTORY
              const Text(
                'Riwayat Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  if (state is WalletLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is WalletLoaded) {
                    if (state.transactions.isEmpty) {
                      return _buildEmptyState('Belum ada transaksi');
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.transactions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = state.transactions[index];
                        final isRevenue = tx.type == 'revenue';

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  (isRevenue
                                          ? AppColors.success
                                          : AppColors.secondary)
                                      .withValues(alpha: 0.1),
                              child: Icon(
                                isRevenue ? Icons.add : Icons.remove,
                                color: isRevenue
                                    ? AppColors.success
                                    : AppColors.secondary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              tx.type == 'revenue'
                                  ? 'Pendapatan Booking'
                                  : 'Penarikan Dana',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'd MMM yyyy, HH:mm',
                                  ).format(tx.createdAt),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (tx.status != 'completed')
                                  Text(
                                    tx.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: tx.status == 'pending'
                                          ? AppColors.warning
                                          : AppColors.error,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Text(
                              (tx.amount > 0 ? '+' : '') +
                                  currencyFormat.format(tx.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: tx.amount > 0
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, int balance) {
    debugPrint('🔵 Masuk fungsi _showWithdrawDialog');
    final profileState = context.read<ProfileBloc>().state;
    debugPrint('🔵 Profile State saat ini: $profileState');
    
    if (profileState is! ProfileLoaded) {
      debugPrint('🔴 Profil belum loaded, menampilkan snackbar');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sedang memuat data profil, coba lagi sesaat lagi...')),
      );
      return;
    }

    final user = profileState.user;
    if (user.bankName == null || user.bankAccountNumber == null) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Lengkapi Data Rekening'),
          content: const Text(
            'Silakan lengkapi informasi rekening bank Anda di halaman Edit Profil sebelum melakukan penarikan dana.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Go to Edit Profile
                // context.push('/profile/edit'); // Use proper route
              },
              child: const Text('Lengkapi Sekarang'),
            ),
          ],
        ),
      );
      return;
    }

    final amountController = TextEditingController(text: balance.toString());
    final bankDetails =
        '${user.bankName} - ${user.bankAccountNumber} a/n ${user.bankAccountHolder}';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tarik Dana'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dana akan dikirim ke:',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              bankDetails,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Jumlah Penarikan',
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(amountController.text) ?? 0;
              if (amount <= 0 || amount > balance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Jumlah penarikan tidak valid')),
                );
                return;
              }
              context.read<WalletBloc>().add(
                RequestPayout(
                  userId: user.uid,
                  amount: amount,
                  bankDetails: bankDetails,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Tarik Sekarang'),
          ),
        ],
      ),
    );
  }
}
