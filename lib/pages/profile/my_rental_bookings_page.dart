import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/services/booking/bookingService.dart';
import 'package:inhabit_realties/pages/widgets/appSpinner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyRentalBookingsPage extends StatefulWidget {
  const MyRentalBookingsPage({super.key});

  @override
  State<MyRentalBookingsPage> createState() => _MyRentalBookingsPageState();
}

class _MyRentalBookingsPageState extends State<MyRentalBookingsPage> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = true;
  List<dynamic> _rentalBookings = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current user ID
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('currentUser');
      if (userJson != null) {
        final userData = Map<String, dynamic>.from(
            Map<String, dynamic>.from(json.decode(userJson)));
        _currentUserId = userData['_id'] ?? userData['id'];
      }

      if (_currentUserId != null) {
        // Load rental bookings only
        final rentalResponse = await _bookingService.getMyRentalBookings(_currentUserId!);
        setState(() {
          _rentalBookings = rentalResponse['data'] ?? [];
        });
      }
    } catch (e) {
      // Handle error silently for now
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackgroundColor = isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor = isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Rental Bookings')),
        body: const Center(child: AppSpinner()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rental Bookings'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: _buildRentalBookingsSection(context, cardBackgroundColor, textColor),
        ),
      ),
    );
  }

  Widget _buildRentalBookingsSection(BuildContext context, Color cardBackgroundColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.house_fill,
                  color: AppColors.brandTurnary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Rental Bookings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.brandTurnary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_rentalBookings.length}',
                    style: TextStyle(
                      color: AppColors.brandTurnary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_rentalBookings.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.house,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No rental bookings found',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _rentalBookings.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) => _buildRentalBookingCard(context, _rentalBookings[index]),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRentalBookingCard(BuildContext context, dynamic booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
    
    return InkWell(
      onTap: () => _navigateToBookingDetails(context, booking),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.brandTurnary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.house_fill,
                color: AppColors.brandTurnary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rental #${booking['_id'].toString().substring(0, 8)}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${booking['monthlyRent']?.toString() ?? '0'} / month',
                    style: TextStyle(
                      color: AppColors.brandTurnary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(booking['startDate'])} - ${_formatDate(booking['endDate'])}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(booking['bookingStatus']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                booking['bookingStatus'] ?? 'PENDING',
                style: TextStyle(
                  color: _getStatusColor(booking['bookingStatus']),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'ACTIVE':
      case 'CONFIRMED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'EXPIRED':
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  void _navigateToBookingDetails(BuildContext context, dynamic booking) {
    Navigator.pushNamed(
      context,
      '/booking_details',
      arguments: {
        'bookingType': 'rental',
        'booking': booking,
      },
    );
  }
}
