class PurchaseBookingModel {
  final String id;
  final String bookingId;
  final String bookingStatus;
  final String propertyId;
  final String customerId;
  final String assignedSalespersonId;
  final double totalPropertyValue;
  final double downPayment;
  final double loanAmount;
  final bool isFinanced;
  final String? bankName;
  final int loanTenure;
  final double interestRate;
  final double emiAmount;
  final String paymentTerms;
  final int installmentCount;
  final List<InstallmentSchedule> installmentSchedule;
  final bool isActive;
  final DateTime? completionDate;
  final String createdByUserId;
  final String updatedByUserId;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated fields
  final Map<String, dynamic>? property;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? assignedSalesperson;

  PurchaseBookingModel({
    required this.id,
    required this.bookingId,
    required this.bookingStatus,
    required this.propertyId,
    required this.customerId,
    required this.assignedSalespersonId,
    required this.totalPropertyValue,
    required this.downPayment,
    required this.loanAmount,
    required this.isFinanced,
    this.bankName,
    required this.loanTenure,
    required this.interestRate,
    required this.emiAmount,
    required this.paymentTerms,
    required this.installmentCount,
    required this.installmentSchedule,
    required this.isActive,
    this.completionDate,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
    this.property,
    this.customer,
    this.assignedSalesperson,
  });

  factory PurchaseBookingModel.fromJson(Map<String, dynamic> json) {
    return PurchaseBookingModel(
      id: json['_id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      bookingStatus: json['bookingStatus'] ?? '',
      propertyId: json['propertyId'] is String
          ? json['propertyId']
          : (json['propertyId']?['_id'] ?? ''),
      customerId: json['customerId'] is String
          ? json['customerId']
          : (json['customerId']?['_id'] ?? ''),
      assignedSalespersonId: json['assignedSalespersonId'] is String
          ? json['assignedSalespersonId']
          : (json['assignedSalespersonId']?['_id'] ?? ''),
      totalPropertyValue: (json['totalPropertyValue'] ?? 0).toDouble(),
      downPayment: (json['downPayment'] ?? 0).toDouble(),
      loanAmount: (json['loanAmount'] ?? 0).toDouble(),
      isFinanced: json['isFinanced'] ?? false,
      bankName: json['bankName'],
      loanTenure: json['loanTenure'] ?? 0,
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      emiAmount: (json['emiAmount'] ?? 0).toDouble(),
      paymentTerms: json['paymentTerms'] ?? '',
      installmentCount: json['installmentCount'] ?? 0,
      installmentSchedule: (json['installmentSchedule'] as List?)
              ?.map((e) => InstallmentSchedule.fromJson(e))
              .toList() ??
          [],
      isActive: json['isActive'] ?? false,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
      createdByUserId: json['createdByUserId'] ?? '',
      updatedByUserId: json['updatedByUserId'] ?? '',
      published: json['published'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      property: json['property'],
      customer: json['customer'],
      assignedSalesperson: json['assignedSalesperson'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bookingId': bookingId,
      'bookingStatus': bookingStatus,
      'propertyId': propertyId,
      'customerId': customerId,
      'assignedSalespersonId': assignedSalespersonId,
      'totalPropertyValue': totalPropertyValue,
      'downPayment': downPayment,
      'loanAmount': loanAmount,
      'isFinanced': isFinanced,
      'bankName': bankName,
      'loanTenure': loanTenure,
      'interestRate': interestRate,
      'emiAmount': emiAmount,
      'paymentTerms': paymentTerms,
      'installmentCount': installmentCount,
      'installmentSchedule':
          installmentSchedule.map((e) => e.toJson()).toList(),
      'isActive': isActive,
      'completionDate': completionDate?.toIso8601String(),
      'createdByUserId': createdByUserId,
      'updatedByUserId': updatedByUserId,
      'published': published,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'property': property,
      'customer': customer,
      'assignedSalesperson': assignedSalesperson,
    };
  }
}

class InstallmentSchedule {
  final int installmentNumber;
  final DateTime dueDate;
  final double amount;
  final String status;
  final DateTime? paidDate;
  final double lateFees;
  final String? paymentId;
  final String responsiblePersonId;
  final String? updatedByUserId;
  final DateTime? updatedAt;

  InstallmentSchedule({
    required this.installmentNumber,
    required this.dueDate,
    required this.amount,
    required this.status,
    this.paidDate,
    required this.lateFees,
    this.paymentId,
    required this.responsiblePersonId,
    this.updatedByUserId,
    this.updatedAt,
  });

  factory InstallmentSchedule.fromJson(Map<String, dynamic> json) {
    return InstallmentSchedule(
      installmentNumber: json['installmentNumber'] ?? 0,
      dueDate: DateTime.parse(json['dueDate']),
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      paidDate:
          json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      lateFees: (json['lateFees'] ?? 0).toDouble(),
      paymentId: json['paymentId'],
      responsiblePersonId: json['responsiblePersonId'] ?? '',
      updatedByUserId: json['updatedByUserId'],
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'installmentNumber': installmentNumber,
      'dueDate': dueDate.toIso8601String(),
      'amount': amount,
      'status': status,
      'paidDate': paidDate?.toIso8601String(),
      'lateFees': lateFees,
      'paymentId': paymentId,
      'responsiblePersonId': responsiblePersonId,
      'updatedByUserId': updatedByUserId,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
