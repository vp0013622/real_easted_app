import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/controllers/property/propertyController.dart';
import 'package:inhabit_realties/controllers/lead/leadsController.dart';
import 'package:inhabit_realties/controllers/user/userController.dart';
import 'package:inhabit_realties/models/property/PropertyModel.dart';
import 'package:inhabit_realties/models/lead/LeadsModel.dart';
import 'package:inhabit_realties/models/auth/UsersModel.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final PropertyController _propertyController = PropertyController();
  final LeadsController _leadsController = LeadsController();
  final UserController _userController = UserController();

  List<PropertyModel> _properties = [];
  List<LeadsModel> _leads = [];
  List<UsersModel> _users = [];
  bool _isLoading = false;
  String _selectedReportType = 'overview';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

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
      await Future.wait([
        _loadProperties(),
        _loadLeads(),
        _loadUsers(),
      ]);
    } catch (error) {
      // Handle error
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadProperties() async {
    final response = await _propertyController.getAllProperties();
    if (response['statusCode'] == 200 && mounted) {
      setState(() {
        _properties = (response['data'] as List)
            .map((item) => PropertyModel.fromJson(item))
            .toList();
      });
    }
  }

  Future<void> _loadLeads() async {
    await _leadsController.loadLeads();
    if (mounted) {
      setState(() {
        _leads = _leadsController.leads;
      });
    }
  }

  Future<void> _loadUsers() async {
    final response = await _userController.getAllUsers();
    if (response['statusCode'] == 200 && mounted) {
      setState(() {
        _users = (response['data'] as List)
            .map((item) => UsersModel.fromJson(item))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports & Analytics',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _loadData,
            tooltip: 'Refresh Reports',
          ),
          IconButton(
            icon: Icon(Icons.download, color: textColor),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
          IconButton(
            icon: Icon(Icons.share, color: textColor),
            onPressed: _shareReport,
            tooltip: 'Share Report',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildReportSelector(),
                    _buildDateRangeSelector(),
                    _buildReportContent(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildReportSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Report Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildReportChip('overview', 'Overview', Icons.dashboard),
              _buildReportChip('properties', 'Properties', Icons.home),
              _buildReportChip('leads', 'Leads', Icons.people),
              _buildReportChip('financial', 'Financial', Icons.attach_money),
              _buildReportChip('performance', 'Performance', Icons.trending_up),
              _buildReportChip('analytics', 'Analytics', Icons.analytics),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportChip(String value, String label, IconData icon) {
    final isSelected = _selectedReportType == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16,
              color: isSelected
                  ? AppColors.lightCardBackground
                  : AppColors.brandPrimary),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedReportType = value;
        });
      },
      selectedColor: AppColors.brandPrimary,
      checkmarkColor: AppColors.lightCardBackground,
      backgroundColor: AppColors.greyColor2,
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildDateField('Start Date', _startDate, (date) {
              setState(() {
                _startDate = date;
              });
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDateField('End Date', _endDate, (date) {
              setState(() {
                _endDate = date;
              });
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
      String label, DateTime date, Function(DateTime) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.greyColor),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (selectedDate != null) {
              onChanged(selectedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyColor2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: AppColors.brandPrimary),
                const SizedBox(width: 8),
                Text(DateFormat('MMM dd, yyyy').format(date)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportContent() {
    switch (_selectedReportType) {
      case 'overview':
        return _buildOverviewReport();
      case 'properties':
        return _buildPropertiesReport();
      case 'leads':
        return _buildLeadsReport();
      case 'financial':
        return _buildFinancialReport();
      case 'performance':
        return _buildPerformanceReport();
      case 'analytics':
        return _buildAnalyticsReport();
      default:
        return _buildOverviewReport();
    }
  }

  Widget _buildOverviewReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportCard(
            'Total Properties',
            _properties.length.toString(),
            Icons.home,
            AppColors.brandPrimary,
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            'Active Leads',
            _leads
                .where((lead) => lead.leadStatus == 'active')
                .length
                .toString(),
            Icons.people,
            AppColors.lightSuccess,
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            'Total Users',
            _users.length.toString(),
            Icons.person,
            AppColors.lightPrimary,
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            'Properties Sold',
            _properties
                .where((prop) => prop.propertyStatus == 'sold')
                .length
                .toString(),
            Icons.check_circle,
            AppColors.lightWarning,
          ),
          const SizedBox(height: 24),
          _buildChartSection(),
        ],
      ),
    );
  }

  Widget _buildReportCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.greyColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Property Status Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusBar(
                'Available',
                _properties
                    .where((p) => p.propertyStatus == 'available')
                    .length,
                _properties.length,
                AppColors.lightSuccess),
            const SizedBox(height: 8),
            _buildStatusBar(
                'Sold',
                _properties.where((p) => p.propertyStatus == 'sold').length,
                _properties.length,
                AppColors.lightWarning),
            const SizedBox(height: 8),
            _buildStatusBar(
                'Under Contract',
                _properties
                    .where((p) => p.propertyStatus == 'under_contract')
                    .length,
                _properties.length,
                AppColors.lightPrimary),
            const SizedBox(height: 8),
            _buildStatusBar(
                'Off Market',
                _properties
                    .where((p) => p.propertyStatus == 'off_market')
                    .length,
                _properties.length,
                AppColors.greyColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$value (${(percentage * 100).toStringAsFixed(1)}%)'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: AppColors.greyColor2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildPropertiesReport() {
    final filteredProperties = _properties.where((property) {
      final propertyDate = property.createdAt;
      return propertyDate.isAfter(_startDate) &&
          propertyDate.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportCard(
            'Total Properties',
            filteredProperties.length.toString(),
            Icons.home,
            AppColors.brandPrimary,
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            'Average Price',
            '\$${_calculateAveragePrice(filteredProperties).toStringAsFixed(0)}',
            Icons.attach_money,
            AppColors.lightSuccess,
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            'Total Value',
            '\$${_calculateTotalValue(filteredProperties).toStringAsFixed(0)}',
            Icons.account_balance_wallet,
            AppColors.lightPrimary,
          ),
          const SizedBox(height: 24),
          const Text(
            'Property Listings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...filteredProperties.map((property) => _buildPropertyCard(property)),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(PropertyModel property) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.brandPrimary.withOpacity(0.1),
          child: Icon(Icons.home, color: AppColors.brandPrimary),
        ),
        title: Text(property.name),
        subtitle: Text(property.propertyAddress.toString()),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${property.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.lightSuccess,
              ),
            ),
            Text(
              property.propertyStatus,
              style: TextStyle(
                fontSize: 12,
                color: _getStatusColor(property.propertyStatus),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'available':
        return AppColors.lightSuccess;
      case 'sold':
        return AppColors.lightWarning;
      case 'under_contract':
        return AppColors.lightPrimary;
      case 'off_market':
        return AppColors.greyColor;
      default:
        return AppColors.greyColor;
    }
  }

  double _calculateAveragePrice(List<PropertyModel> properties) {
    if (properties.isEmpty) return 0;
    final totalPrice =
        properties.fold(0.0, (sum, property) => sum + property.price);
    return totalPrice / properties.length;
  }

  double _calculateTotalValue(List<PropertyModel> properties) {
    return properties.fold(0.0, (sum, property) => sum + property.price);
  }

  Widget _buildLeadsReport() {
    return const Center(child: Text('Leads Report - Coming Soon'));
  }

  Widget _buildFinancialReport() {
    return const Center(child: Text('Financial Report - Coming Soon'));
  }

  Widget _buildPerformanceReport() {
    return const Center(child: Text('Performance Report - Coming Soon'));
  }

  Widget _buildAnalyticsReport() {
    return const Center(child: Text('Analytics Report - Coming Soon'));
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
      ),
    );
  }

  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }
}
