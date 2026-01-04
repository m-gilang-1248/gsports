import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:intl/intl.dart';

enum TimeFilter { day, week, month, custom }

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
  DateTimeRange? _selectedDateRange;

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
              _buildFilterSection(),
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
          if (_selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${DateFormat('d MMM').format(_selectedDateRange!.start)} - ${DateFormat('d MMM yyyy').format(_selectedDateRange!.end)}',
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

  Widget _buildFilterSection() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _pickDateRange,
          icon: Icon(
            Icons.calendar_month,
            size: 20,
            color: _selectedDateRange != null ? AppColors.primary : Colors.grey,
          ),
          visualDensity: VisualDensity.compact,
        ),
        _buildFilterDropdown(),
      ],
    );
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
        _selectedFilter = TimeFilter.custom;
      });
    }
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
            if (newValue != null && newValue != TimeFilter.custom) {
              setState(() {
                _selectedFilter = newValue;
                _selectedDateRange = null;
              });
            }
          },
          items: [
            const DropdownMenuItem(value: TimeFilter.day, child: Text('Hari')),
            const DropdownMenuItem(value: TimeFilter.week, child: Text('Minggu')),
            const DropdownMenuItem(value: TimeFilter.month, child: Text('Bulan')),
            if (_selectedFilter == TimeFilter.custom)
              const DropdownMenuItem(value: TimeFilter.custom, child: Text('Kustom')),
          ],
        ),
      ),
    );
  }

  List<Booking> _getFilteredData() {
    final now = DateTime.now();
    return widget.data.where((booking) {
      final date = booking.date;

      if (_selectedDateRange != null) {
        // Range check (inclusive)
        final start = DateTime(
          _selectedDateRange!.start.year,
          _selectedDateRange!.start.month,
          _selectedDateRange!.start.day,
        );
        final end = DateTime(
          _selectedDateRange!.end.year,
          _selectedDateRange!.end.month,
          _selectedDateRange!.end.day,
          23,
          59,
          59,
        );
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end.add(const Duration(seconds: 1)));
      }

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
        case TimeFilter.custom:
          return false; // Should be handled by _selectedDateRange
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
    bool groupByHour = _selectedFilter == TimeFilter.day;

    if (_selectedFilter == TimeFilter.custom && _selectedDateRange != null) {
      final diff = _selectedDateRange!.duration.inDays;
      groupByHour = diff <= 1;
    }

    for (final booking in filteredData) {
      int key;
      if (groupByHour) {
        key = booking.startTime.hour;
      } else if (_selectedFilter == TimeFilter.week) {
        key = booking.date.weekday;
      } else if (_selectedFilter == TimeFilter.month) {
        key = booking.date.day;
      } else if (_selectedFilter == TimeFilter.custom &&
          _selectedDateRange != null) {
        // Use day of year or similar to handle cross-month
        // For simplicity in X-axis (0 to duration), we can use diff from start
        key = booking.date.difference(_selectedDateRange!.start).inDays;
      } else {
        key = booking.date.day;
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
    } else if (_selectedFilter == TimeFilter.week) {
      for (int i = 1; i <= 7; i++) {
        spots.add(FlSpot(i.toDouble(), aggregated[i] ?? 0));
      }
    } else if (_selectedFilter == TimeFilter.custom &&
        _selectedDateRange != null) {
      final days = _selectedDateRange!.duration.inDays;
      for (int i = 0; i <= days; i++) {
        spots.add(FlSpot(i.toDouble(), aggregated[i] ?? 0));
      }
    } else {
      final sortedKeys = aggregated.keys.toList()..sort();
      for (final key in sortedKeys) {
        spots.add(FlSpot(key.toDouble(), aggregated[key]!));
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
              bool groupByHour = _selectedFilter == TimeFilter.day;
              if (_selectedFilter == TimeFilter.custom &&
                  _selectedDateRange != null) {
                groupByHour = _selectedDateRange!.duration.inDays <= 1;
              }

              if (groupByHour) {
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
              } else if (_selectedFilter == TimeFilter.custom &&
                  _selectedDateRange != null) {
                final date = _selectedDateRange!.start.add(
                  Duration(days: value.toInt()),
                );
                text = DateFormat('d/M').format(date);
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
