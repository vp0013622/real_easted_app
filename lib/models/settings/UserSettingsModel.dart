class UserSettingsModel {
  final String id;
  final String userId;
  final NotificationSettings notificationSettings;
  final DisplaySettings displaySettings;
  final PrivacySettings privacySettings;
  final ReportSettings reportSettings;
  final ThemeSettings themeSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettingsModel({
    required this.id,
    required this.userId,
    required this.notificationSettings,
    required this.displaySettings,
    required this.privacySettings,
    required this.reportSettings,
    required this.themeSettings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      notificationSettings:
          NotificationSettings.fromJson(json['notificationSettings'] ?? {}),
      displaySettings: DisplaySettings.fromJson(json['displaySettings'] ?? {}),
      privacySettings: PrivacySettings.fromJson(json['privacySettings'] ?? {}),
      reportSettings: ReportSettings.fromJson(json['reportSettings'] ?? {}),
      themeSettings: ThemeSettings.fromJson(json['themeSettings'] ?? {}),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'notificationSettings': notificationSettings.toJson(),
      'displaySettings': displaySettings.toJson(),
      'privacySettings': privacySettings.toJson(),
      'reportSettings': reportSettings.toJson(),
      'themeSettings': themeSettings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    try {
      if (dateValue == null) return DateTime.now();
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) return DateTime.parse(dateValue);
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  UserSettingsModel copyWith({
    String? id,
    String? userId,
    NotificationSettings? notificationSettings,
    DisplaySettings? displaySettings,
    PrivacySettings? privacySettings,
    ReportSettings? reportSettings,
    ThemeSettings? themeSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      displaySettings: displaySettings ?? this.displaySettings,
      privacySettings: privacySettings ?? this.privacySettings,
      reportSettings: reportSettings ?? this.reportSettings,
      themeSettings: themeSettings ?? this.themeSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NotificationSettings {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool leadNotifications;
  final bool propertyNotifications;
  final bool documentNotifications;
  final bool reportNotifications;
  final String notificationTime; // "09:00", "18:00", etc.
  final List<String> notificationDays; // ["monday", "tuesday", etc.]

  NotificationSettings({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.leadNotifications = true,
    this.propertyNotifications = true,
    this.documentNotifications = true,
    this.reportNotifications = true,
    this.notificationTime = "09:00",
    this.notificationDays = const [
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday"
    ],
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotifications: json['pushNotifications'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      smsNotifications: json['smsNotifications'] ?? false,
      leadNotifications: json['leadNotifications'] ?? true,
      propertyNotifications: json['propertyNotifications'] ?? true,
      documentNotifications: json['documentNotifications'] ?? true,
      reportNotifications: json['reportNotifications'] ?? true,
      notificationTime: json['notificationTime'] ?? "09:00",
      notificationDays: List<String>.from(json['notificationDays'] ??
          ["monday", "tuesday", "wednesday", "thursday", "friday"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'leadNotifications': leadNotifications,
      'propertyNotifications': propertyNotifications,
      'documentNotifications': documentNotifications,
      'reportNotifications': reportNotifications,
      'notificationTime': notificationTime,
      'notificationDays': notificationDays,
    };
  }

  NotificationSettings copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? leadNotifications,
    bool? propertyNotifications,
    bool? documentNotifications,
    bool? reportNotifications,
    String? notificationTime,
    List<String>? notificationDays,
  }) {
    return NotificationSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      leadNotifications: leadNotifications ?? this.leadNotifications,
      propertyNotifications:
          propertyNotifications ?? this.propertyNotifications,
      documentNotifications:
          documentNotifications ?? this.documentNotifications,
      reportNotifications: reportNotifications ?? this.reportNotifications,
      notificationTime: notificationTime ?? this.notificationTime,
      notificationDays: notificationDays ?? this.notificationDays,
    );
  }
}

class DisplaySettings {
  final String language; // "en", "es", "fr", etc.
  final String dateFormat; // "MM/dd/yyyy", "dd/MM/yyyy", etc.
  final String timeFormat; // "12h", "24h"
  final String currency; // "USD", "EUR", "GBP", etc.
  final String currencySymbol; // "$", "€", "£", etc.
  final bool showCurrencySymbol;
  final int itemsPerPage; // 10, 20, 50, etc.
  final bool compactMode;
  final bool showImages;
  final String defaultView; // "list", "grid", "card"

  DisplaySettings({
    this.language = "en",
    this.dateFormat = "MM/dd/yyyy",
    this.timeFormat = "12h",
    this.currency = "INR",
    this.currencySymbol = "₹",
    this.showCurrencySymbol = true,
    this.itemsPerPage = 20,
    this.compactMode = false,
    this.showImages = true,
    this.defaultView = "list",
  });

  factory DisplaySettings.fromJson(Map<String, dynamic> json) {
    return DisplaySettings(
      language: json['language'] ?? "en",
      dateFormat: json['dateFormat'] ?? "MM/dd/yyyy",
      timeFormat: json['timeFormat'] ?? "12h",
      currency: json['currency'] ?? "INR",
      currencySymbol: json['currencySymbol'] ?? "₹",
      showCurrencySymbol: json['showCurrencySymbol'] ?? true,
      itemsPerPage: json['itemsPerPage'] ?? 20,
      compactMode: json['compactMode'] ?? false,
      showImages: json['showImages'] ?? true,
      defaultView: json['defaultView'] ?? "list",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'currency': currency,
      'currencySymbol': currencySymbol,
      'showCurrencySymbol': showCurrencySymbol,
      'itemsPerPage': itemsPerPage,
      'compactMode': compactMode,
      'showImages': showImages,
      'defaultView': defaultView,
    };
  }

  DisplaySettings copyWith({
    String? language,
    String? dateFormat,
    String? timeFormat,
    String? currency,
    String? currencySymbol,
    bool? showCurrencySymbol,
    int? itemsPerPage,
    bool? compactMode,
    bool? showImages,
    String? defaultView,
  }) {
    return DisplaySettings(
      language: language ?? this.language,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      showCurrencySymbol: showCurrencySymbol ?? this.showCurrencySymbol,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      compactMode: compactMode ?? this.compactMode,
      showImages: showImages ?? this.showImages,
      defaultView: defaultView ?? this.defaultView,
    );
  }
}

class PrivacySettings {
  final bool shareProfile;
  final bool showOnlineStatus;
  final bool allowMessages;
  final bool showContactInfo;
  final bool allowLocationSharing;
  final bool dataAnalytics;
  final bool marketingEmails;
  final bool thirdPartySharing;

  PrivacySettings({
    this.shareProfile = true,
    this.showOnlineStatus = true,
    this.allowMessages = true,
    this.showContactInfo = true,
    this.allowLocationSharing = false,
    this.dataAnalytics = true,
    this.marketingEmails = false,
    this.thirdPartySharing = false,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      shareProfile: json['shareProfile'] ?? true,
      showOnlineStatus: json['showOnlineStatus'] ?? true,
      allowMessages: json['allowMessages'] ?? true,
      showContactInfo: json['showContactInfo'] ?? true,
      allowLocationSharing: json['allowLocationSharing'] ?? false,
      dataAnalytics: json['dataAnalytics'] ?? true,
      marketingEmails: json['marketingEmails'] ?? false,
      thirdPartySharing: json['thirdPartySharing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shareProfile': shareProfile,
      'showOnlineStatus': showOnlineStatus,
      'allowMessages': allowMessages,
      'showContactInfo': showContactInfo,
      'allowLocationSharing': allowLocationSharing,
      'dataAnalytics': dataAnalytics,
      'marketingEmails': marketingEmails,
      'thirdPartySharing': thirdPartySharing,
    };
  }

  PrivacySettings copyWith({
    bool? shareProfile,
    bool? showOnlineStatus,
    bool? allowMessages,
    bool? showContactInfo,
    bool? allowLocationSharing,
    bool? dataAnalytics,
    bool? marketingEmails,
    bool? thirdPartySharing,
  }) {
    return PrivacySettings(
      shareProfile: shareProfile ?? this.shareProfile,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      allowMessages: allowMessages ?? this.allowMessages,
      showContactInfo: showContactInfo ?? this.showContactInfo,
      allowLocationSharing: allowLocationSharing ?? this.allowLocationSharing,
      dataAnalytics: dataAnalytics ?? this.dataAnalytics,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      thirdPartySharing: thirdPartySharing ?? this.thirdPartySharing,
    );
  }
}

class ReportSettings {
  final String defaultReportType; // "overview", "properties", "leads", etc.
  final String defaultDateRange; // "7d", "30d", "90d", "1y", "custom"
  final bool autoRefresh;
  final int refreshInterval; // in minutes
  final bool showCharts;
  final bool showDetails;
  final List<String> favoriteReports;
  final String exportFormat; // "pdf", "excel", "csv"
  final bool emailReports;
  final String emailSchedule; // "daily", "weekly", "monthly", "never"

  ReportSettings({
    this.defaultReportType = "overview",
    this.defaultDateRange = "30d",
    this.autoRefresh = false,
    this.refreshInterval = 30,
    this.showCharts = true,
    this.showDetails = true,
    this.favoriteReports = const [],
    this.exportFormat = "pdf",
    this.emailReports = false,
    this.emailSchedule = "never",
  });

  factory ReportSettings.fromJson(Map<String, dynamic> json) {
    return ReportSettings(
      defaultReportType: json['defaultReportType'] ?? "overview",
      defaultDateRange: json['defaultDateRange'] ?? "30d",
      autoRefresh: json['autoRefresh'] ?? false,
      refreshInterval: json['refreshInterval'] ?? 30,
      showCharts: json['showCharts'] ?? true,
      showDetails: json['showDetails'] ?? true,
      favoriteReports: List<String>.from(json['favoriteReports'] ?? []),
      exportFormat: json['exportFormat'] ?? "pdf",
      emailReports: json['emailReports'] ?? false,
      emailSchedule: json['emailSchedule'] ?? "never",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultReportType': defaultReportType,
      'defaultDateRange': defaultDateRange,
      'autoRefresh': autoRefresh,
      'refreshInterval': refreshInterval,
      'showCharts': showCharts,
      'showDetails': showDetails,
      'favoriteReports': favoriteReports,
      'exportFormat': exportFormat,
      'emailReports': emailReports,
      'emailSchedule': emailSchedule,
    };
  }

  ReportSettings copyWith({
    String? defaultReportType,
    String? defaultDateRange,
    bool? autoRefresh,
    int? refreshInterval,
    bool? showCharts,
    bool? showDetails,
    List<String>? favoriteReports,
    String? exportFormat,
    bool? emailReports,
    String? emailSchedule,
  }) {
    return ReportSettings(
      defaultReportType: defaultReportType ?? this.defaultReportType,
      defaultDateRange: defaultDateRange ?? this.defaultDateRange,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      showCharts: showCharts ?? this.showCharts,
      showDetails: showDetails ?? this.showDetails,
      favoriteReports: favoriteReports ?? this.favoriteReports,
      exportFormat: exportFormat ?? this.exportFormat,
      emailReports: emailReports ?? this.emailReports,
      emailSchedule: emailSchedule ?? this.emailSchedule,
    );
  }
}

class ThemeSettings {
  final String themeMode; // "light", "dark", "auto"
  final String primaryColor; // hex color code
  final String accentColor; // hex color code
  final bool useSystemTheme;
  final bool highContrast;
  final bool reduceMotion;
  final double fontSize; // 0.8, 1.0, 1.2, 1.4, etc.

  ThemeSettings({
    this.themeMode = "auto",
    this.primaryColor = "#2196F3",
    this.accentColor = "#FF4081",
    this.useSystemTheme = true,
    this.highContrast = false,
    this.reduceMotion = false,
    this.fontSize = 1.0,
  });

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      themeMode: json['themeMode'] ?? "auto",
      primaryColor: json['primaryColor'] ?? "#2196F3",
      accentColor: json['accentColor'] ?? "#FF4081",
      useSystemTheme: json['useSystemTheme'] ?? true,
      highContrast: json['highContrast'] ?? false,
      reduceMotion: json['reduceMotion'] ?? false,
      fontSize: (json['fontSize'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'primaryColor': primaryColor,
      'accentColor': accentColor,
      'useSystemTheme': useSystemTheme,
      'highContrast': highContrast,
      'reduceMotion': reduceMotion,
      'fontSize': fontSize,
    };
  }

  ThemeSettings copyWith({
    String? themeMode,
    String? primaryColor,
    String? accentColor,
    bool? useSystemTheme,
    bool? highContrast,
    bool? reduceMotion,
    double? fontSize,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      highContrast: highContrast ?? this.highContrast,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}
 