import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/core/services/iap_service.dart';
import 'package:gsports/features/auth/domain/repositories/auth_repository.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_event.dart';
import 'package:gsports/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumUpgradeDialog extends StatefulWidget {
  const PremiumUpgradeDialog({super.key});

  @override
  State<PremiumUpgradeDialog> createState() => _PremiumUpgradeDialogState();
}

class _PremiumUpgradeDialogState extends State<PremiumUpgradeDialog> {
  late StreamSubscription<PurchaseDetails> _purchaseSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final iapService = GetIt.I<IapService>();
    _purchaseSubscription = iapService.purchaseStream.listen((purchase) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _handleSuccess();
      } else if (purchase.status == PurchaseStatus.error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase Error: ${purchase.error}')),
        );
      } else if (purchase.status == PurchaseStatus.canceled) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _handleSuccess() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final repository = GetIt.I<AuthRepository>();
      await repository.updateUserTier(uid: authState.user.uid, tier: 'premium');

      if (!mounted) return;

      context.read<AuthBloc>().add(AuthCheckRequested());
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selamat! Anda sekarang adalah anggota Premium.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _purchaseSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Upgrade ke Premium',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBenefitRow(Icons.block, 'Bebas Iklan (No Ads)'),
          const SizedBox(height: 12),
          _buildBenefitRow(Icons.all_inclusive, 'Scoreboard Tanpa Batas'),
          const SizedBox(height: 12),
          _buildBenefitRow(Icons.star_outline, 'Prioritas Booking'),
          const SizedBox(height: 24),
          const Text(
            'Hanya Rp 1.000 / bulan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  setState(() => _isLoading = true);
                  try {
                    await GetIt.I<IapService>().buyPremium();
                  } catch (e) {
                    if (mounted) {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Berlangganan Sekarang'),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Mungkin Nanti'),
        ),
      ],
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
