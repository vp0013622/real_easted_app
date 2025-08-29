import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/constants/role_utils.dart';
import 'package:inhabit_realties/models/booking/rental_booking_model.dart';
import 'package:inhabit_realties/services/booking/admin_booking_service.dart';
import 'package:inhabit_realties/pages/widgets/loader.dart';
import 'package:intl/intl.dart';

class AllRentalBookingsPage extends StatefulWidget {
  const AllRentalBookingsPage({super.key});

  @override
  State<AllRentalBookingsPage> createState() => _AllRentalBookingsPageState();
}

class _AllRentalBookingsPageState extends State<AllRentalBookingsPage> {
  final AdminBookingService _bookingService = AdminBookingService();
  List<RentalBookingModel> _bookings = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _bookingService.getAllRentalBookings();

      // Check if data exists (API returns data directly without statusCode)
      if (response['data'] != null) {
        final List<dynamic> bookingsData = response['data'];
        final List<RentalBookingModel> bookings = bookingsData
            .map((json) => RentalBookingModel.fromJson(json))
            .toList();

        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load bookings';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  /// Confirm a rental booking by changing its status to ACTIVE
  Future<void> _confirmBooking(String bookingId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _bookingService.confirmRentalBooking(bookingId);

      if (response['data'] != null) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rental booking confirmed successfully!'),
            backgroundColor: AppColors.successColor(
                Theme.of(context).brightness == Brightness.dark),
          ),
        );

        // Reload bookings to show updated status
        await _loadBookings();
      } else {
        throw Exception(
            response['message'] ?? 'Failed to confirm rental booking');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error confirming rental booking: $e'),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkDanger
              : AppColors.lightDanger,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<RentalBookingModel> get _filteredBookings {
    return _bookings.where((booking) {
      final matchesSearch = _searchQuery.isEmpty ||
          booking.bookingId
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (booking.property?['name'] ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (booking.customer?['name'] ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesStatus = _statusFilter == 'ALL' ||
          booking.bookingStatus.toUpperCase() == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  String _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return '#FFA500'; // Orange
      case 'ACTIVE':
        return '#4CAF50'; // Green
      case 'EXPIRED':
        return '#F44336'; // Red
      case 'CANCELLED':
        return '#9C27B0'; // Purple
      default:
        return '#757575'; // Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('All Rental Bookings'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: cardColor,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by booking ID, property, or customer...',
                    prefixIcon: const Icon(CupertinoIcons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(CupertinoIcons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor:
                        isDark ? AppColors.darkBackground : Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Status Filter
                Row(
                  children: [
                    Text(
                      'Status: ',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'ALL',
                            'PENDING',
                            'ACTIVE',
                            'EXPIRED',
                            'CANCELLED'
                          ]
                              .map((status) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(status),
                                      selected: _statusFilter == status,
                                      onSelected: (_) {
                                        setState(() {
                                          _statusFilter = status;
                                        });
                                      },
                                      backgroundColor: isDark
                                          ? AppColors.darkBackground
                                          : Colors.grey[200],
                                      selectedColor: isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.brandPrimary,
                                      labelStyle: TextStyle(
                                        color: _statusFilter == status
                                            ? Colors.white
                                            : textColor,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bookings List
          Expanded(
            child: _isLoading
                ? const Center(child: Loader())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.exclamationmark_triangle,
                              size: 64,
                              color: Colors.orange[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadBookings,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredBookings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.house,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No rental bookings found',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty ||
                                    _statusFilter != 'ALL')
                                  Text(
                                    'Try adjusting your search or filters',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadBookings,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredBookings.length,
                              itemBuilder: (context, index) {
                                final booking = _filteredBookings[index];
                                return _buildBookingCard(
                                    booking, isDark, cardColor, textColor);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(RentalBookingModel booking, bool isDark,
      Color cardColor, Color textColor) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final dateFormat = DateFormat('MMM dd, yyyy');
    final brandColor =
        isDark ? AppColors.brandSecondary : AppColors.brandPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking ID: ${booking.bookingId}',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created: ${DateFormat('MMM dd, yyyy').format(booking.createdAt)}',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: brandColor),
                    borderRadius: BorderRadius.circular(20),
                    color: brandColor.withOpacity(0.1),
                  ),
                  child: Text(
                    booking.bookingStatus.toUpperCase(),
                    style: TextStyle(
                      color: brandColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Confirm Button (only show for PENDING bookings)
            if (booking.bookingStatus == 'PENDING')
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: () {
                    // Show confirmation dialog before confirming
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Rental Booking'),
                          content: Text(
                              'Are you sure you want to confirm this rental booking? This will change the status from PENDING to ACTIVE.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _confirmBooking(booking.bookingId);
                              },
                              child: Text('Confirm'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm Booking',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            // Property Info
            if (booking.property != null) ...[
              _buildInfoRow(
                  'Property', booking.property!['name'] ?? 'N/A', textColor),
              _buildInfoRow(
                  'Location',
                  '${booking.property!['propertyAddress']?['city'] ?? ''}, ${booking.property!['propertyAddress']?['state'] ?? ''}',
                  textColor),
            ] else if (booking.propertyId is Map) ...[
              _buildInfoRow(
                  'Property',
                  (booking.propertyId as Map<String, dynamic>)['name'] ?? 'N/A',
                  textColor),
              _buildInfoRow(
                  'Location',
                  '${(booking.propertyId as Map<String, dynamic>)['propertyAddress']?['city'] ?? ''}, ${(booking.propertyId as Map<String, dynamic>)['propertyAddress']?['state'] ?? ''}',
                  textColor),
            ] else ...[
              _buildInfoRow('Property', 'ID: ${booking.propertyId}', textColor),
            ],
            // Customer Info
            if (booking.customer != null) ...[
              _buildInfoRow(
                  'Customer', booking.customer!['name'] ?? 'N/A', textColor),
              _buildInfoRow(
                  'Phone', booking.customer!['phone'] ?? 'N/A', textColor),
            ] else if (booking.customerId is Map) ...[
              _buildInfoRow(
                  'Customer',
                  (booking.customerId as Map<String, dynamic>)['name'] ?? 'N/A',
                  textColor),
              _buildInfoRow(
                  'Phone',
                  (booking.customerId as Map<String, dynamic>)['phone'] ??
                      'N/A',
                  textColor),
            ] else ...[
              _buildInfoRow('Customer', 'ID: ${booking.customerId}', textColor),
            ],
            // Salesperson Info
            if (booking.assignedSalesperson != null) ...[
              _buildInfoRow('Salesperson',
                  booking.assignedSalesperson!['name'] ?? 'N/A', textColor),
            ] else if (booking.assignedSalespersonId is Map) ...[
              _buildInfoRow(
                  'Salesperson',
                  (booking.assignedSalespersonId
                          as Map<String, dynamic>)['name'] ??
                      'N/A',
                  textColor),
            ] else ...[
              _buildInfoRow('Salesperson',
                  'ID: ${booking.assignedSalespersonId}', textColor),
            ],
            const SizedBox(height: 12),
            // Rental Period
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.greyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rental Period',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Start Date',
                      dateFormat.format(booking.startDate), textColor),
                  _buildInfoRow('End Date', dateFormat.format(booking.endDate),
                      textColor),
                  _buildInfoRow(
                      'Duration', '${booking.duration} months', textColor),
                  _buildInfoRow('Rent Due Date',
                      '${booking.rentDueDate}th of month', textColor),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Financial Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.greyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Details',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Monthly Rent',
                      currencyFormat.format(booking.monthlyRent), textColor),
                  if (booking.securityDeposit > 0)
                    _buildInfoRow(
                        'Security Deposit',
                        currencyFormat.format(booking.securityDeposit),
                        textColor),
                  if (booking.maintenanceCharges > 0)
                    _buildInfoRow(
                        'Maintenance Charges',
                        currencyFormat.format(booking.maintenanceCharges),
                        textColor),
                  if (booking.advanceRent > 0)
                    _buildInfoRow('Advance Rent',
                        currencyFormat.format(booking.advanceRent), textColor),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Show confirmation dialog before navigating
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('View Rental Booking Details'),
                            content: Text(
                                'Are you sure you want to view the details of rental booking ${booking.bookingId}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Show "coming soon" message instead of navigating
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Feature Coming Soon'),
                                        content: Text(
                                            'The rental booking details feature will be available in the next update.'),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text('View Details'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Show confirmation dialog before editing
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Edit Rental Booking'),
                            content: Text(
                                'Are you sure you want to edit rental booking ${booking.bookingId}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // TODO: Implement edit functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Edit functionality coming soon!'),
                                      backgroundColor: AppColors.warningColor(
                                          Theme.of(context).brightness ==
                                              Brightness.dark),
                                    ),
                                  );
                                },
                                child: Text('Edit'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.brandPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
