import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/controllers/lead/leadsController.dart';
import 'package:inhabit_realties/models/lead/LeadsModel.dart';
import 'package:inhabit_realties/pages/leads/widgets/appAppBar.dart';
import 'package:inhabit_realties/pages/leads/widgets/addNewLeadButton.dart';
import 'package:inhabit_realties/pages/widgets/appCard.dart';
import 'package:inhabit_realties/pages/widgets/appSpinner.dart';
import 'package:inhabit_realties/pages/widgets/app_search_bar.dart';
import 'package:inhabit_realties/pages/leads/lead_details_page.dart';
import 'package:inhabit_realties/services/lead/leadsService.dart';
import 'package:inhabit_realties/models/lead/LeadStatusModel.dart';
import 'package:inhabit_realties/models/lead/FollowUpStatusModel.dart';
import 'package:inhabit_realties/models/lead/ReferenceSourceModel.dart';
import 'package:inhabit_realties/services/user/userService.dart';
import 'package:inhabit_realties/models/auth/UsersModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:inhabit_realties/providers/leads_page_provider.dart';
import 'package:inhabit_realties/constants/status_utils.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> with TickerProviderStateMixin {
  final LeadsController _leadsController = LeadsController();
  final LeadsService _leadsService = LeadsService();
  final UserService _userService = UserService();
  late final AnimationController _animationController;
  late final AnimationController _staggerController;
  late final Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();

  bool isPageLoading = false;
  bool isInitialLoading = true;
  List<LeadsModel> leads = [];
  List<LeadsModel> filteredLeads = [];

  // Filter data
  List<LeadStatusModel> leadStatuses = [];
  List<FollowUpStatusModel> followUpStatuses = [];
  List<ReferenceSourceModel> referenceSources = [];
  List<UsersModel> users = [];

  // Filter values
  String? selectedLeadStatus;
  String? selectedFollowUpStatus;
  String? selectedReferenceSource;
  String? selectedAssignedBy;
  String? selectedAssignedTo;
  String searchQuery = '';
  bool isFilterVisible = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _staggerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isPageLoading = true;
      isInitialLoading = true;
    });

    try {
      await Future.wait([
        _leadsController.loadLeads(),
        _loadFilterData(),
      ]);

      if (mounted) {
        setState(() {
          leads = _leadsController.leads;
          filteredLeads = List.from(leads);
          isPageLoading = false;
          isInitialLoading = false;
        });
        _animationController.forward();
        _staggerController.forward();
      }
    } catch (error) {
      // Handle error silently
    }
  }

  Future<void> _loadFilterData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final currentUser = prefs.getString('currentUser') ?? '';
      final decodedCurrentUser = jsonDecode(currentUser);
      final userId = decodedCurrentUser['_id'] ?? '';

      // Load lead statuses
      final leadStatusResult =
          await _leadsService.getAllLeadStatuses(token, userId);
      if (leadStatusResult['statusCode'] == 200) {
        final statusData = leadStatusResult['data'] as List;
        leadStatuses =
            statusData.map((json) => LeadStatusModel.fromJson(json)).toList();
        // Update StatusUtils with the loaded statuses
        StatusUtils.setLeadStatuses(leadStatuses);
      }

      // Load follow-up statuses
      final followUpResult =
          await _leadsService.getAllFollowUpStatuses(token, userId);
      if (followUpResult['statusCode'] == 200) {
        final followUpData = followUpResult['data'] as List;
        followUpStatuses = followUpData
            .map((json) => FollowUpStatusModel.fromJson(json))
            .toList();
        // Update StatusUtils with the loaded follow-up statuses
        StatusUtils.setFollowUpStatuses(followUpStatuses);
      }

      // Load reference sources
      final referenceResult =
          await _leadsService.getAllReferenceSources(token, userId);
      if (referenceResult['statusCode'] == 200) {
        final referenceData = referenceResult['data'] as List;
        referenceSources = referenceData
            .map((json) => ReferenceSourceModel.fromJson(json))
            .toList();
      }

      // Load users for assigned by/to filters
      final usersResult = await _userService.getAllUsers(token);
      if (usersResult['statusCode'] == 200) {
        final usersData = usersResult['data'] as List;
        users = usersData.map((json) => UsersModel.fromJson(json)).toList();
      }
    } catch (error) {
      // Handle error silently
    }
  }

  void _applyFilters() {
    setState(() {
      filteredLeads = leads.where((lead) {
        // Lead status filter
        if (selectedLeadStatus != null &&
            lead.leadStatus != selectedLeadStatus) {
          return false;
        }

        // Follow-up status filter
        if (selectedFollowUpStatus != null &&
            lead.followUpStatus != selectedFollowUpStatus) {
          return false;
        }

        // Reference source filter
        if (selectedReferenceSource != null &&
            lead.referanceFrom?.id != selectedReferenceSource) {
          return false;
        }

        // Assigned by filter
        if (selectedAssignedBy != null &&
            lead.assignedByUserId != selectedAssignedBy) {
          return false;
        }

        // Assigned to filter
        if (selectedAssignedTo != null &&
            lead.assignedToUserId != selectedAssignedTo) {
          return false;
        }

        // Search filter
        if (searchQuery.isNotEmpty) {
          final firstName = lead.leadFirstName.toLowerCase();
          final lastName = lead.leadLastName.toLowerCase();
          final email = lead.leadEmail.toLowerCase();
          final phone = lead.leadPhoneNumber.toLowerCase();
          final searchLower = searchQuery.toLowerCase();

          if (!firstName.contains(searchLower) &&
              !lastName.contains(searchLower) &&
              !email.contains(searchLower) &&
              !phone.contains(searchLower)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      selectedLeadStatus = null;
      selectedFollowUpStatus = null;
      selectedReferenceSource = null;
      selectedAssignedBy = null;
      selectedAssignedTo = null;
      searchQuery = '';
      _searchController.clear();
      filteredLeads = List.from(leads);
    });
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query;
    });
    _applyFilters();
  }

  // Helper methods to extract user information from the lead
  String _getLeadFirstName(LeadsModel lead) {
    return lead.leadFirstName;
  }

  String _getLeadLastName(LeadsModel lead) {
    return lead.leadLastName;
  }

  String _getLeadEmail(LeadsModel lead) {
    return lead.leadEmail;
  }

  String _getLeadPhone(LeadsModel lead) {
    return lead.leadPhoneNumber;
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
    final secondaryTextColor =
        isDark ? AppColors.greyColor : AppColors.greyColor2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Leads',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
              ),
              Text(
                '${filteredLeads.length} leads found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final secondaryTextColor =
        isDark ? AppColors.greyColor : AppColors.greyColor2;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          AppSearchBar(
            controller: _searchController,
            onChanged: _handleSearch,
            hintText: 'Search by name, email, phone...',
          ),
          const SizedBox(height: 12),
          // Filter dropdowns in a grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterDropdown(
                'Lead Status',
                selectedLeadStatus,
                leadStatuses.map((status) => status.name).toList(),
                (value) {
                  setState(() {
                    selectedLeadStatus = value;
                  });
                  _applyFilters();
                },
                secondaryTextColor,
              ),
              _buildFilterDropdown(
                'Follow-up Status',
                selectedFollowUpStatus,
                followUpStatuses.map((status) => status.name).toList(),
                (value) {
                  setState(() {
                    selectedFollowUpStatus = value;
                  });
                  _applyFilters();
                },
                secondaryTextColor,
              ),
              _buildFilterDropdown(
                'Reference Source',
                selectedReferenceSource,
                referenceSources.map((source) => source.name).toList(),
                (value) {
                  setState(() {
                    selectedReferenceSource = value;
                  });
                  _applyFilters();
                },
                secondaryTextColor,
              ),
              _buildFilterDropdown(
                'Assigned By',
                selectedAssignedBy,
                users
                    .map((user) => '${user.firstName} ${user.lastName}')
                    .toList(),
                (value) {
                  setState(() {
                    selectedAssignedBy = value;
                  });
                  _applyFilters();
                },
                secondaryTextColor,
              ),
              _buildFilterDropdown(
                'Assigned To',
                selectedAssignedTo,
                users
                    .map((user) => '${user.firstName} ${user.lastName}')
                    .toList(),
                (value) {
                  setState(() {
                    selectedAssignedTo = value;
                  });
                  _applyFilters();
                },
                secondaryTextColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Clear filters button (only show when filters are active)
          if (selectedLeadStatus != null ||
              selectedFollowUpStatus != null ||
              selectedReferenceSource != null ||
              selectedAssignedBy != null ||
              selectedAssignedTo != null ||
              searchQuery.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear, size: 14),
                label:
                    const Text('Clear Filters', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.lightDanger,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String? selectedValue,
    List<String> options,
    Function(String?) onChanged,
    Color textColor,
  ) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: textColor.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Text(
                'All',
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withOpacity(0.6),
                ),
              ),
              isExpanded: true,
              underline: Container(),
              icon: Icon(Icons.arrow_drop_down, size: 16, color: textColor),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All', style: TextStyle(fontSize: 11)),
                ),
                ...options
                    .map((option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadsList() {
    if (isPageLoading) {
      return const Center(child: AppSpinner());
    }

    if (filteredLeads.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.greyColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people_outline,
                        size: 64,
                        color: AppColors.greyColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No leads found',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.greyColor2,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first lead to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.greyColor,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: filteredLeads.length,
        itemBuilder: (context, index) {
          final lead = filteredLeads[index];
          final animationDelay = index * 0.1;

          return AnimatedBuilder(
            animation: _staggerController,
            builder: (context, child) {
              final animationValue = Curves.easeOutCubic.transform(
                (_staggerController.value - animationDelay).clamp(0.0, 1.0),
              );

              return Transform.translate(
                offset: Offset(0, 50 * (1 - animationValue)),
                child: _buildLeadCard(lead, index),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLeadCard(LeadsModel lead, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
    final secondaryTextColor =
        isDark ? AppColors.greyColor : AppColors.greyColor2;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LeadDetailsPage(lead: lead),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCardBackground
                  : AppColors.lightCardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Profile Image/Avatar
                _buildProfileAvatar(lead, index),
                const SizedBox(width: 16),

                // Lead Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lead.fullName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                            ),
                          ),
                          _buildStatusChip(lead.leadStatus),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Email
                      _buildInfoRow(
                        Icons.email_outlined,
                        lead.leadEmail,
                        secondaryTextColor,
                      ),
                      const SizedBox(height: 4),

                      // Phone
                      _buildInfoRow(
                        Icons.phone_outlined,
                        lead.leadPhoneNumber,
                        secondaryTextColor,
                      ),
                      const SizedBox(height: 8),

                      // Follow-up Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getFollowUpStatusColor(lead.followUpStatus)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getFollowUpStatusColor(lead.followUpStatus)
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getFollowUpStatusDisplayName(lead.followUpStatus),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _getFollowUpStatusColor(
                                        lead.followUpStatus),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(LeadsModel lead, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarColors = [
      AppColors.lightPrimary,
      AppColors.brandPrimary,
      AppColors.lightSuccess,
      AppColors.lightWarning,
      AppColors.lightDanger,
    ];

    final colorIndex = index % avatarColors.length;
    final avatarColor = avatarColors[colorIndex];

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: avatarColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: avatarColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          lead.fullName.isNotEmpty ? lead.fullName[0].toUpperCase() : 'L',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: avatarColor,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.darkWhiteText,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    return StatusUtils.getLeadStatusColor(status);
  }

  Color _getFollowUpStatusColor(String status) {
    return StatusUtils.getFollowUpStatusColor(status);
  }

  String _getFollowUpStatusDisplayName(String status) {
    return StatusUtils.getFollowUpStatusDisplayName(status);
  }

  String _getStatusDisplayName(String status) {
    return StatusUtils.getLeadStatusDisplayName(status);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: LeadsAppBar(
        actions: [
          // Filter button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isFilterVisible
                  ? AppColors.brandPrimary
                  : AppColors.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  isFilterVisible = !isFilterVisible;
                });
              },
              icon: Icon(
                Icons.filter_list,
                color: isFilterVisible
                    ? AppColors.darkWhiteText
                    : AppColors.brandPrimary,
                size: 20,
              ),
              tooltip: 'Toggle Filters',
            ),
          ),
          // Add Lead button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AddNewLeadButton(
              onLeadAdded: _loadData,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            if (isFilterVisible) _buildFilterSection(),
            Expanded(child: _buildLeadsList()),
          ],
        ),
      ),
    );
  }
}
