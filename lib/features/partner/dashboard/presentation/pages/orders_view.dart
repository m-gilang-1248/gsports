import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gsports/core/config/app_colors.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/partner/booking_management/presentation/bloc/order_management_bloc.dart';
import 'package:gsports/features/partner/booking_management/presentation/widgets/booking_order_card.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _viewIndex = 0; // 0 for List, 1 for Calendar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controls Section
        Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      label: Text('Daftar'),
                      icon: Icon(Icons.list),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text('Kalender'),
                      icon: Icon(Icons.calendar_month),
                    ),
                  ],
                  selected: {_viewIndex},
                  onSelectionChanged: (value) {
                    setState(() => _viewIndex = value.first);
                  },
                ),
              ),
              if (_viewIndex == 0)
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Masuk'),
                    Tab(text: 'Jadwal'),
                    Tab(text: 'Riwayat'),
                  ],
                ),
            ],
          ),
        ),
        
        // Content Section
        Expanded(
          child: BlocBuilder<OrderManagementBloc, OrderManagementState>(
            builder: (context, state) {
              if (state is OrderManagementLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is OrderManagementLoaded) {
                if (_viewIndex == 1) {
                  return _CalendarView(state: state);
                }
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _BookingListView(bookings: state.pendingBookings),
                    _BookingListView(bookings: state.upcomingBookings),
                    _BookingListView(bookings: state.historyBookings),
                  ],
                );
              } else if (state is OrderManagementFailure) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _BookingListView extends StatelessWidget {
  final List<Booking> bookings;

  const _BookingListView({required this.bookings});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderManagementBloc>().add(FetchPartnerBookings());
      },
      child: bookings.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada pesanan',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                return BookingOrderCard(
                  booking: bookings[index],
                  onTap: () => context.push(
                    '/partner/booking-detail/${bookings[index].id}',
                  ),
                );
              },
            ),
    );
  }
}

class _CalendarView extends StatelessWidget {
  final OrderManagementLoaded state;

  const _CalendarView({required this.state});

  @override
  Widget build(BuildContext context) {
    // Normalization logic helper
    DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

    final selectedDayBookings =
        state.bookingsByDate[normalize(state.selectedDay ?? DateTime.now())] ??
        [];

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: state.focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(state.selectedDay, day),
            eventLoader: (day) => state.bookingsByDate[normalize(day)] ?? [],
            onDaySelected: (selectedDay, focusedDay) {
              context.read<OrderManagementBloc>().add(
                UpdateCalendarFocusedDay(focusedDay, selectedDay),
              );
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _BookingListView(bookings: selectedDayBookings)),
      ],
    );
  }
}