import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../constants/contants.dart';
import '../../controllers/lead/leadsController.dart';
import '../../models/auth/UsersModel.dart';
import '../../models/lead/LeadsModel.dart';

class ActivityDetailsPage extends StatefulWidget {
  final String title;
  final int count;

  const ActivityDetailsPage({
    Key? key,
    required this.title,
    required this.count,
  }) : super(key: key);

  @override
  State<ActivityDetailsPage> createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> {
  bool _isLoading = true;
  List<LeadsModel> _leads = [];
  UsersModel? _currentUser;
  final LeadsController _leadsController = LeadsController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load current user
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('currentUser');
      if (userJson != null) {
        final userData = json.decode(userJson);
        _currentUser = UsersModel.fromJson(userData);
      }

      // Load leads based on activity type
      await _loadLeadsByType();
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLeadsByType() async {
    try {
      // Load all leads first
      await _leadsController.loadLeads();

      // Filter based on activity type
      List<LeadsModel> filteredLeads = [];

      switch (widget.title) {
        case 'Total Leads':
          filteredLeads = _leadsController.leads;
          break;
        case 'Active Leads':
          filteredLeads = _leadsController.leads
              .where((lead) => lead.leadStatus.toLowerCase() == 'active')
              .toList();
          break;
        case 'Completed Leads':
          filteredLeads = _leadsController.leads
              .where((lead) => lead.leadStatus.toLowerCase() == 'completed')
              .toList();
          break;
        default:
          filteredLeads = _leadsController.leads;
      }

      setState(() {
        _leads = filteredLeads;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackgroundColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: cardBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: () => _loadData(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.brandPrimary,
                        AppColors.brandSecondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandPrimary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIconForActivity(),
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_leads.length} items',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Leads List
                Expanded(
                  child: _leads.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: AppColors.greyColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No ${widget.title.toLowerCase()} found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.greyColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _leads.length,
                          itemBuilder: (context, index) {
                            final lead = _leads[index];
                            return _buildLeadCard(
                                context, lead, cardBackgroundColor);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildLeadCard(
      BuildContext context, LeadsModel lead, Color cardBackgroundColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  lead.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(lead.leadStatus),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  lead.leadStatus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (lead.leadEmail.isNotEmpty) ...[
            Text(
              'Email: ${lead.leadEmail}',
              style: TextStyle(
                color: AppColors.greyColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (lead.leadPhoneNumber.isNotEmpty) ...[
            Text(
              'Phone: ${lead.leadPhoneNumber}',
              style: TextStyle(
                color: AppColors.greyColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (lead.leadDesignation.isNotEmpty) ...[
            Text(
              'Designation: ${lead.leadDesignation}',
              style: TextStyle(
                color: AppColors.greyColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            'Created: ${_formatDate(lead.createdAt)}',
            style: TextStyle(
              color: AppColors.greyColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForActivity() {
    switch (widget.title) {
      case 'Total Leads':
        return CupertinoIcons.person_2_square_stack_fill;
      case 'Active Leads':
        return Icons.trending_up_outlined;
      case 'Completed Leads':
        return CupertinoIcons.checkmark_circle_fill;
      default:
        return Icons.analytics_outlined;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}
