import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/pages/widgets/appSpinner.dart';
import 'package:inhabit_realties/services/property/propertyService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookingDetailsPage extends StatefulWidget {
  final String bookingType; // 'rental' or 'purchase'
  final Map<String, dynamic> booking;

  const BookingDetailsPage({
    super.key,
    required this.bookingType,
    required this.booking,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  final PropertyService _propertyService = PropertyService();
  bool _isLoadingProperty = true;
  Map<String, dynamic>? _propertyDetails;

  @override
  void initState() {
    super.initState();
    _loadPropertyDetails();
  }

  Future<void> _loadPropertyDetails() async {
    try {
      final propertyId = widget.booking['propertyId'];
      if (propertyId != null) {
        // Get token from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        
        if (token != null) {
          final propertyResponse = await _propertyService.getPropertyById(token, propertyId);
          if (propertyResponse['statusCode'] == 200) {
            setState(() {
              _propertyDetails = propertyResponse['data'];
              _isLoadingProperty = false;
            });
          } else {
            setState(() {
              _isLoadingProperty = false;
            });
          }
        } else {
          setState(() {
            _isLoadingProperty = false;
          });
        }
      } else {
        setState(() {
          _isLoadingProperty = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingProperty = false;
      });
      // Handle error silently for now
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackgroundColor = isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor = isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bookingType.capitalize()} Booking Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Header Card
            _buildBookingHeaderCard(context, cardBackgroundColor, textColor),
            
            const SizedBox(height: 20),
            
            // Property Details Card
            if (_propertyDetails != null) _buildPropertyCard(context, cardBackgroundColor, textColor),
            
            const SizedBox(height: 20),
            
            // Booking Details Card
            _buildBookingDetailsCard(context, cardBackgroundColor, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingHeaderCard(BuildContext context, Color cardBackgroundColor, Color textColor) {
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.brandTurnary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.bookingType == 'rental' 
                        ? CupertinoIcons.house_fill 
                        : CupertinoIcons.bag_fill,
                    color: AppColors.brandTurnary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.bookingType.capitalize()} #${widget.booking['_id'].toString().substring(0, 8)}',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.booking['bookingStatus']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.booking['bookingStatus'] ?? 'PENDING',
                          style: TextStyle(
                            color: _getStatusColor(widget.booking['bookingStatus']),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Created on ${_formatDate(widget.booking['createdAt'])}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, Color cardBackgroundColor, Color textColor) {
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.house_fill,
                  color: AppColors.brandTurnary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Property Details',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                // Eye button to navigate to property details
                InkWell(
                  onTap: () => _navigateToPropertyDetails(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandTurnary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      CupertinoIcons.eye_fill,
                      color: AppColors.brandTurnary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_propertyDetails != null) ...[
              Text(
                _propertyDetails!['propertyName'] ?? 'Property Name',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.location_fill,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _propertyDetails!['address']?['fullAddress'] ?? 'Address not available',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.money_dollar_circle_fill,
                    color: AppColors.brandTurnary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${_propertyDetails!['propertyValue']?.toString() ?? '0'}',
                    style: TextStyle(
                      color: AppColors.brandTurnary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Center(
                child: AppSpinner(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard(BuildContext context, Color cardBackgroundColor, Color textColor) {
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.doc_text_fill,
                  color: AppColors.brandTurnary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Booking Details',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.bookingType == 'rental') ...[
              _buildDetailRow('Monthly Rent', '₹${widget.booking['monthlyRent']?.toString() ?? '0'}', textColor),
              _buildDetailRow('Security Deposit', '₹${widget.booking['securityDeposit']?.toString() ?? '0'}', textColor),
              _buildDetailRow('Maintenance Charges', '₹${widget.booking['maintenanceCharges']?.toString() ?? '0'}', textColor),
              _buildDetailRow('Start Date', _formatDate(widget.booking['startDate']), textColor),
              _buildDetailRow('End Date', _formatDate(widget.booking['endDate']), textColor),
            ] else ...[
              _buildDetailRow('Total Property Value', '₹${widget.booking['totalPropertyValue']?.toString() ?? '0'}', textColor),
              _buildDetailRow('Down Payment', '₹${widget.booking['downPayment']?.toString() ?? '0'}', textColor),
              _buildDetailRow('Loan Amount', '₹${widget.booking['loanAmount']?.toString() ?? '0'}', textColor),
              _buildDetailRow('Payment Terms', widget.booking['paymentTerms'] ?? 'INSTALLMENTS', textColor),
              _buildDetailRow('Installment Count', '${widget.booking['installmentCount']?.toString() ?? '0'}', textColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
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

  void _navigateToPropertyDetails(BuildContext context) {
    if (_propertyDetails != null) {
      Navigator.pushNamed(
        context,
        '/property_details',
        arguments: {'property': _propertyDetails},
      );
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
