import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:intl/intl.dart';

enum ChartType { bookings, revenue }

class StatsChartCard extends StatefulWidget {
  final String title;
  final ChartType type;
  final List<Booking> data;

  const StatsChartCard({
    super.key,
    required this.title,
    required this.type,
    required this.data,
  });

  @override
  State<StatsChartCard> createState() => _StatsChartCardState();
}

class _StatsChartCardState extends State<StatsChartCard> {
  late DateTimeRange _selectedDateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _getFilteredData();
    final totalValue = _calculateTotal(filteredData);
    final spots = _generateSpots(filteredData);

    final isToday = _isToday(_selectedDateRange);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: _pickDateRange,
                icon: const Icon(
                  Icons.calendar_month,
                  size: 20,
                  color: AppColors.primary,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatValue(totalValue),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              isToday
                  ? 'Hari Ini'
                  : '${DateFormat('d MMM').format(_selectedDateRange.start)} - ${DateFormat('d MMM yyyy').format(_selectedDateRange.end)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: spots.isEmpty
                ? const Center(child: Text('Tidak ada data'))
                : LineChart(_buildChartData(spots)),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTimeRange range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return range.start.isAtSameMomentAs(today) &&
        range.end.isAtSameMomentAs(today);
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  List<Booking> _getFilteredData() {
    return widget.data.where((booking) {
      final date = booking.date;

      // Range check (inclusive)
      final start = DateTime(
        _selectedDateRange.start.year,
        _selectedDateRange.start.month,
        _selectedDateRange.start.day,
      );
      final end = DateTime(
        _selectedDateRange.end.year,
        _selectedDateRange.end.month,
        _selectedDateRange.end.day,
        23,
        59,
        59,
      );
      return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          date.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
  }

  double _calculateTotal(List<Booking> filteredData) {
    if (widget.type == ChartType.bookings) {
      return filteredData.length.toDouble();
    } else {
      return filteredData
          .where(
            (b) => b.paymentStatus == 'paid' || b.paymentStatus == 'settled',
          )
          .fold(0.0, (sum, b) => sum + b.totalPrice);
    }
  }

  String _formatValue(double value) {
    if (widget.type == ChartType.bookings) {
      return value.toInt().toString();
    } else {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(value);
    }
  }

  String _formatYAxisLabel(double value) {
    if (widget.type == ChartType.bookings) {
      return value.toInt().toString();
    } else {
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}jt';
      } else if (value >= 1000) {
        return '${(value / 1000).toInt()}rb';
      }
      return value.toInt().toString();
    }
  }

  List<FlSpot> _generateSpots(List<Booking> filteredData) {
    if (filteredData.isEmpty) return [];

    final Map<int, double> aggregated = {};
    final bool groupByHour = _selectedDateRange.duration.inDays < 1;

    for (final booking in filteredData) {
      int key;
      if (groupByHour) {
        key = booking.startTime.hour;
      } else {
        // Use day difference from start
        key = booking.date.difference(_selectedDateRange.start).inDays;
      }

      double value = 1.0;
      if (widget.type == ChartType.revenue) {
        if (booking.paymentStatus != 'paid' &&
            booking.paymentStatus != 'settled') {
          continue;
        }
        value = booking.totalPrice.toDouble();
      }

      aggregated[key] = (aggregated[key] ?? 0) + value;
    }

    if (aggregated.isEmpty) return [];

    final List<FlSpot> spots = [];
    if (groupByHour) {
      for (int i = 0; i < 24; i++) {
        spots.add(FlSpot(i.toDouble(), aggregated[i] ?? 0));
      }
    } else {
      final days = _selectedDateRange.duration.inDays;
      for (int i = 0; i <= days; i++) {
        spots.add(FlSpot(i.toDouble(), aggregated[i] ?? 0));
      }
    }

    return spots;
  }

  LineChartData _buildChartData(List<FlSpot> spots) {
    double maxY = 0;
    for (final spot in spots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    // Add 20% buffer to maxY
    maxY = maxY == 0 ? 10 : maxY * 1.2;

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _getBottomInterval(spots.length),
            getTitlesWidget: (value, meta) {
              String text = '';
              final bool groupByHour = _selectedDateRange.duration.inDays < 1;

              if (groupByHour) {
                if (value % 4 == 0) text = '${value.toInt()}:00';
              } else {
                final date = _selectedDateRange.start.add(
                  Duration(days: value.toInt()),
                );
                text = DateFormat('d/M').format(date);
              }
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: widget.type == ChartType.revenue ? 45 : 30,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  _formatYAxisLabel(value),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: widget.type == ChartType.bookings
              ? AppColors.secondary
              : AppColors.success,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color:
                (widget.type == ChartType.bookings
                        ? AppColors.secondary
                        : AppColors.success)
                    .withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  double _getBottomInterval(int length) {
    if (length > 20) return 5;
    if (length > 10) return 2;
    return 1;
  }
}
