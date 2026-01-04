import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:intl/intl.dart';

enum TimeFilter { day, week, month }

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
  TimeFilter _selectedFilter = TimeFilter.day;

  @override
  Widget build(BuildContext context) {
    final filteredData = _getFilteredData();
    final totalValue = _calculateTotal(filteredData);
    final spots = _generateSpots(filteredData);

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
              _buildFilterDropdown(),
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

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TimeFilter>(
          value: _selectedFilter,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (TimeFilter? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFilter = newValue;
              });
            }
          },
          items: const [
            DropdownMenuItem(value: TimeFilter.day, child: Text('Hari')),
            DropdownMenuItem(value: TimeFilter.week, child: Text('Minggu')),
            DropdownMenuItem(value: TimeFilter.month, child: Text('Bulan')),
          ],
        ),
      ),
    );
  }

  List<Booking> _getFilteredData() {
    final now = DateTime.now();
    return widget.data.where((booking) {
      final date = booking.date;
      switch (_selectedFilter) {
        case TimeFilter.day:
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        case TimeFilter.week:
          final weekAgo = now.subtract(const Duration(days: 7));
          return date.isAfter(weekAgo);
        case TimeFilter.month:
          return date.year == now.year && date.month == now.month;
      }
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

  List<FlSpot> _generateSpots(List<Booking> filteredData) {
    if (filteredData.isEmpty) return [];

    final Map<int, double> aggregated = {};

    for (final booking in filteredData) {
      int key;
      switch (_selectedFilter) {
        case TimeFilter.day:
          key = booking.startTime.hour;
          break;
        case TimeFilter.week:
          key = booking.date.weekday;
          break;
        case TimeFilter.month:
          key = booking.date.day;
          break;
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
    final sortedKeys = aggregated.keys.toList()..sort();

    // Fill gaps with 0 for better chart look
    if (_selectedFilter == TimeFilter.day) {
      for (int i = 0; i < 24; i++) {
        spots.add(FlSpot(i.toDouble(), aggregated[i] ?? 0));
      }
    } else if (_selectedFilter == TimeFilter.week) {
      for (int i = 1; i <= 7; i++) {
        spots.add(FlSpot(i.toDouble(), aggregated[i] ?? 0));
      }
    } else {
      for (final key in sortedKeys) {
        spots.add(FlSpot(key.toDouble(), aggregated[key]!));
      }
    }

    return spots;
  }

  LineChartData _buildChartData(List<FlSpot> spots) {
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
            interval: _selectedFilter == TimeFilter.month ? 5 : 1,
            getTitlesWidget: (value, meta) {
              String text = '';
              if (_selectedFilter == TimeFilter.day) {
                if (value % 4 == 0) text = '${value.toInt()}:00';
              } else if (_selectedFilter == TimeFilter.week) {
                const days = [
                  '',
                  'Sen',
                  'Sel',
                  'Rab',
                  'Kam',
                  'Jum',
                  'Sab',
                  'Min',
                ];
                if (value >= 1 && value <= 7) text = days[value.toInt()];
              } else {
                text = value.toInt().toString();
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
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
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
}
