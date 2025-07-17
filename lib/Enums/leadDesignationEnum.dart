class LeadDesignation {
  // Constants for lead designations
  static const String buyer = 'buyer';
  static const String tenant = 'tenant';
  static const String other = 'other';

  // List of all valid designations
  static const List<String> values = [buyer, tenant, other];

  // Get display label for a designation
  static String getLabel(String designation) {
    switch (designation.toLowerCase().trim()) {
      case buyer:
        return 'Buyer';
      case tenant:
        return 'Tenant';
      case other:
        return 'Other';
      default:
        return 'Other';
    }
  }

  // Validate if a designation is valid
  static bool isValid(String designation) {
    return values.contains(designation.toLowerCase().trim());
  }

  // Get default designation
  static String getDefault() {
    return other;
  }

  // Parse designation from string with fallback
  static String fromString(String value) {
    if (value.isEmpty) return getDefault();

    final normalizedValue = value.toLowerCase().trim();

    switch (normalizedValue) {
      case buyer:
      case 'buyers':
        return buyer;
      case tenant:
      case 'tenants':
        return tenant;
      case other:
      case 'others':
        return other;
      default:
        return getDefault();
    }
  }
}
