import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/constants/status_utils.dart';
import 'package:inhabit_realties/controllers/user/userController.dart';
import 'package:inhabit_realties/models/lead/LeadsModel.dart';
import 'package:inhabit_realties/models/lead/LeadStatusModel.dart';
import 'package:inhabit_realties/models/lead/FollowUpStatusModel.dart';
import 'package:inhabit_realties/pages/leads/lead_details_page.dart';
import 'package:inhabit_realties/pages/widgets/appSpinner.dart';
import 'package:inhabit_realties/pages/widgets/profile_avatar.dart';
import 'package:inhabit_realties/widgets/notification_badge.dart';
import 'package:provider/provider.dart';
import 'package:inhabit_realties/controllers/notification/notificationController.dart';
import 'package:inhabit_realties/services/lead/leadsService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AssignedLeadsPage extends StatefulWidget {
  const AssignedLeadsPage({super.key});

  @override
  State<AssignedLeadsPage> createState() => _AssignedLeadsPageState();
}

class _AssignedLeadsPageState extends State<AssignedLeadsPage> {
  final UserController _userController = UserController();
  final LeadsService _leadsService = LeadsService();
  List<LeadsModel> _assignedLeads = [];
  List<LeadsModel> _filteredLeads = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'All';

  // Status data
  List<LeadStatusModel> _leadStatuses = [];
  List<FollowUpStatusModel> _followUpStatuses = [];

  List<String> get _statusOptions {
    return ['All', ..._leadStatuses.map((status) => status.name).toList()];
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadLeadStatuses();
    await _loadFollowUpStatuses();
    await _loadAssignedLeads();
  }

  Future<void> _loadLeadStatuses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final currentUser = prefs.getString('currentUser') ?? '';
      final decodedCurrentUser = jsonDecode(currentUser);
      final userId = decodedCurrentUser['_id'] ?? '';

      final response = await _leadsService.getAllLeadStatuses(token, userId);
      if (response['statusCode'] == 200 && mounted) {
        setState(() {
          _leadStatuses = (response['data'] as List)
              .map((item) => LeadStatusModel.fromJson(item))
              .toList();
        });
        // Update StatusUtils with the loaded statuses
        StatusUtils.setLeadStatuses(_leadStatuses);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadFollowUpStatuses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final currentUser = prefs.getString('currentUser') ?? '';
      final decodedCurrentUser = jsonDecode(currentUser);
      final userId = decodedCurrentUser['_id'] ?? '';

      final response =
          await _leadsService.getAllFollowUpStatuses(token, userId);
      if (response['statusCode'] == 200 && mounted) {
        setState(() {
          _followUpStatuses = (response['data'] as List)
              .map((item) => FollowUpStatusModel.fromJson(item))
              .toList();
        });
        // Update StatusUtils with the loaded statuses
        StatusUtils.setFollowUpStatuses(_followUpStatuses);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadAssignedLeads() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final leads = await _userController.getAssignedLeadsNew();

      // Sort leads by createdAt date (latest first)
      leads.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!
            .compareTo(a.createdAt!); // Descending order (newest first)
      });

      setState(() {
        _assignedLeads = leads;
        _filteredLeads = leads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Error handled silently
    }
  }

  void _filterLeads() {
    setState(() {
      _filteredLeads = _assignedLeads.where((lead) {
        // Search filter
        final matchesSearch = lead.fullName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            lead.leadEmail.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            lead.leadPhoneNumber.contains(_searchQuery);

        // Status filter
        final matchesStatus = _statusFilter == 'All' ||
            StatusUtils.getLeadStatusDisplayName(lead.leadStatus ?? '') ==
                _statusFilter;

        return matchesSearch && matchesStatus;
      }).toList();

      // Maintain sorting by createdAt date (latest first) after filtering
      _filteredLeads.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!
            .compareTo(a.createdAt!); // Descending order (newest first)
      });
    });
  }

  Color _getStatusColor(String? status) {
    return StatusUtils.getLeadStatusColor(status ?? '');
  }

  String _getDesignationDisplayName(String designation) {
    // Handle common designations
    switch (designation.toUpperCase()) {
      case 'BUYER':
        return 'Buyer';
      case 'SELLER':
        return 'Seller';
      case 'INVESTOR':
        return 'Investor';
      case 'TENANT':
        return 'Tenant';
      case 'LANDLORD':
        return 'Landlord';
      default:
        // If it's an ObjectId or unknown, return a default
        if (designation.length == 24 &&
            RegExp(r'^[a-fA-F0-9]+$').hasMatch(designation)) {
          return 'Unknown';
        }
        return designation.isNotEmpty ? designation : 'Unknown';
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
          'My Assigned Leads',
          style: TextStyle(
            color: isDark ? AppColors.darkWhiteText : AppColors.lightDarkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cardBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? AppColors.darkWhiteText : AppColors.lightDarkText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const NotificationBadgeWithLoading(),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? AppColors.darkWhiteText : AppColors.lightDarkText,
            ),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: cardBackgroundColor,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterLeads();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search leads...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor:
                        isDark ? AppColors.darkBackground : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                // Status Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      isExpanded: true,
                      hint: const Text('Filter by status'),
                      items: _statusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _statusFilter = newValue!;
                          _filterLeads();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Stats Section
          Container(
            padding: const EdgeInsets.all(16),
            color: cardBackgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    '${_filteredLeads.length}',
                    AppColors.brandPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    '${_filteredLeads.where((lead) => lead.leadStatus?.toLowerCase() == 'active').length}',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    '${_filteredLeads.where((lead) => lead.leadStatus?.toLowerCase() == 'pending').length}',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    '${_filteredLeads.where((lead) => lead.leadStatus?.toLowerCase() == 'completed').length}',
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          // Leads List
          Expanded(
            child: _isLoading
                ? const Center(child: AppSpinner())
                : _filteredLeads.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadAssignedLeads,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredLeads.length,
                          itemBuilder: (context, index) {
                            final lead = _filteredLeads[index];
                            return _buildLeadCard(
                                lead, cardBackgroundColor, textColor);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No assigned leads found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Leads assigned to you will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(
      LeadsModel lead, Color cardBackgroundColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ProfileAvatar(
          userId: lead.userId,
          userName: lead.fullName,
          size: 50,
        ),
        title: Text(
          lead.fullName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              lead.leadEmail,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              lead.leadPhoneNumber,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(lead.leadStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    StatusUtils.getLeadStatusDisplayName(lead.leadStatus ?? ''),
                    style: TextStyle(
                      color: _getStatusColor(lead.leadStatus),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDesignationDisplayName(lead.leadDesignation),
                    style: TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: textColor.withOpacity(0.5),
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LeadDetailsPage(lead: lead),
            ),
          );
        },
      ),
    );
  }
}
