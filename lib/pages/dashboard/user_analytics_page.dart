import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/services/dashboard/dashboardService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class UserAnalyticsPage extends StatefulWidget {
  const UserAnalyticsPage({super.key});

  @override
  State<UserAnalyticsPage> createState() => _UserAnalyticsPageState();
}

class _UserAnalyticsPageState extends State<UserAnalyticsPage> {
  bool _isLoading = true;
  Map<String, dynamic> _analyticsData = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserAnalytics();
  }

  Future<void> _loadUserAnalytics() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await DashboardService.getUserAnalytics(token);

      if (!mounted) return;
      if (response['statusCode'] == 200) {
        setState(() {
          _analyticsData = response['data'];
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load user analytics');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
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
          'User Analytics',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: cardColor,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _loadUserAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : _buildAnalyticsContent(),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 200,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading analytics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserAnalytics,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return RefreshIndicator(
      onRefresh: _loadUserAnalytics,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCards(),
            const SizedBox(height: 24),
            _buildRoleDistributionChart(),
            const SizedBox(height: 24),
            _buildUserPerformanceList(), // <-- Add this line
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total Users',
          _analyticsData['totalUsers']?.toString() ?? '0',
          CupertinoIcons.person_2,
          AppColors.brandPrimary,
        ),
        _buildStatCard(
          'Active Users',
          _getActiveUsersCount().toString(),
          CupertinoIcons.person_circle,
          AppColors.lightSuccess,
        ),
        _buildStatCard(
          'Top Performers',
          _getTopPerformersCount().toString(),
          CupertinoIcons.star,
          AppColors.lightWarning,
        ),
        _buildStatCard(
          'Avg Performance',
          '${_getAveragePerformance().toStringAsFixed(1)}%',
          CupertinoIcons.chart_bar,
          AppColors.brandTurnary,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDistributionChart() {
    final roleData = _analyticsData['roleDistribution'] ?? {};
    if (roleData.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'User Role Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: roleData.entries
                    .map((entry) {
                      double total = 0;
                      for (final value in roleData.values) {
                        if (value is int) {
                          total += value.toDouble();
                        } else if (value is double) {
                          total += value;
                        }
                      }

                      double entryValue = 0;
                      if (entry.value is int) {
                        entryValue = entry.value.toDouble();
                      } else if (entry.value is double) {
                        entryValue = entry.value;
                      }

                      final percentage =
                          total > 0 ? (entryValue / total) * 100 : 0;

                      return PieChartSectionData(
                        value: entryValue,
                        title:
                            '${entry.key}\n${percentage.toStringAsFixed(1)}%',
                        radius: 60,
                        color: _getRoleColor(entry.key),
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    })
                    .toList()
                    .cast<PieChartSectionData>(),
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPerformanceItem(Map<String, dynamic> user) {
    final totalLeads = user['totalLeads'] ?? 0;
    final activeLeads = user['activeLeads'] ?? 0;
    final totalProperties = user['totalProperties'] ?? 0;
    final soldProperties = user['soldProperties'] ?? 0;
    final userName = user['userName'] ?? 'Unknown User';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceMetric(
                    'Leads', totalLeads.toString(), AppColors.brandPrimary),
              ),
              Expanded(
                child: _buildPerformanceMetric(
                    'Active', activeLeads.toString(), AppColors.lightSuccess),
              ),
              Expanded(
                child: _buildPerformanceMetric('Properties',
                    totalProperties.toString(), AppColors.lightWarning),
              ),
              Expanded(
                child: _buildPerformanceMetric(
                    'Sold', soldProperties.toString(), AppColors.brandTurnary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  int _getActiveUsersCount() {
    final userPerformance = _analyticsData['userPerformance'] ?? [];
    return userPerformance.where((user) {
      final totalLeads = user['totalLeads'];
      if (totalLeads is int) return totalLeads > 0;
      if (totalLeads is double) return totalLeads > 0;
      return false;
    }).length;
  }

  int _getTopPerformersCount() {
    final userPerformance = _analyticsData['userPerformance'] ?? [];
    return userPerformance.where((user) {
      final soldProperties = user['soldProperties'];
      if (soldProperties is int) return soldProperties > 0;
      if (soldProperties is double) return soldProperties > 0;
      return false;
    }).length;
  }

  double _getAveragePerformance() {
    final userPerformance = _analyticsData['userPerformance'] ?? [];
    if (userPerformance.isEmpty) return 0.0;

    double totalLeads = 0;
    double convertedLeads = 0;

    for (final user in userPerformance) {
      final userTotalLeads = user['totalLeads'];
      final userSoldProperties = user['soldProperties'];

      if (userTotalLeads is int) {
        totalLeads += userTotalLeads.toDouble();
      } else if (userTotalLeads is double) {
        totalLeads += userTotalLeads;
      }

      if (userSoldProperties is int) {
        convertedLeads += userSoldProperties.toDouble();
      } else if (userSoldProperties is double) {
        convertedLeads += userSoldProperties;
      }
    }

    return totalLeads > 0 ? (convertedLeads / totalLeads) * 100 : 0.0;
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return AppColors.brandPrimary;
      case 'SALES':
        return AppColors.lightSuccess;
      case 'EXECUTIVE':
        return AppColors.lightWarning;
      case 'USER':
        return AppColors.lightPrimary;
      default:
        return AppColors.brandTurnary;
    }
  }

  Widget _buildUserPerformanceList() {
    final userPerformance = _analyticsData['userPerformance'] ?? [];
    if (userPerformance.isEmpty) {
      return Center(
        child: Text(
          'No user performance data available',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Performance',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...userPerformance
            .map<Widget>(
                (user) => _buildUserPerformanceItem(_fixUserPerformance(user)))
            .toList(),
      ],
    );
  }

  Map<String, dynamic> _fixUserPerformance(Map<String, dynamic> user) {
    // Fallback for userName
    String userName = user['userName'] ?? '';
    if (userName.trim().isEmpty || userName.toLowerCase().contains('unknown')) {
      final firstName = user['firstName'] ?? '';
      final lastName = user['lastName'] ?? '';
      userName = (firstName + ' ' + lastName).trim();
      if (userName.isEmpty) userName = 'User';
    }
    return {
      ...user,
      'userName': userName,
    };
  }
}
