import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gsports/core/config/app_colors.dart';

class PaymentTimerWidget extends StatefulWidget {
  final DateTime createdAt;
  final VoidCallback? onExpired;

  const PaymentTimerWidget({
    super.key,
    required this.createdAt,
    this.onExpired,
  });

  @override
  State<PaymentTimerWidget> createState() => _PaymentTimerWidgetState();
}

class _PaymentTimerWidgetState extends State<PaymentTimerWidget> {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateRemaining();
    });
  }

  void _calculateRemaining() {
    final deadline = widget.createdAt.add(const Duration(minutes: 15));
    final now = DateTime.now();
    final diff = deadline.difference(now);

    if (diff.isNegative || diff.inSeconds == 0) {
      if (!_isExpired) {
        setState(() {
          _remaining = Duration.zero;
          _isExpired = true;
        });
        widget.onExpired?.call();
      }
      _timer.cancel();
    } else {
      setState(() {
        _remaining = diff;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timer_off_outlined,
              color: AppColors.error,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Waktu Pembayaran Habis',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Text(
            'Sisa Waktu Bayar: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _formatDuration(_remaining),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
