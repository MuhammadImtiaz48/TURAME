import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum PaymentMethodType { mtnMobile, airtelMoney, stripe, visaCard, mastercard }

enum TransactionStatus { success, failed, pending }

class OrderSummaryModel {
  final String providerName;
  final String serviceType;
  final double consultationFee;
  final double serviceFee;
  final String currency;

  const OrderSummaryModel({
    required this.providerName,
    required this.serviceType,
    required this.consultationFee,
    required this.serviceFee,
    this.currency = 'RWF',
  });

  double get total => consultationFee + serviceFee;

  String get formattedTotal => _fmt(total);

  String formattedAmount(double amount) => _fmt(amount);

  String _fmt(double v) =>
      '$currency ${v.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          )}';
}

class PaymentMethodModel {
  final String id;
  final String name;
  final String subtitle;
  final PaymentMethodType type;
  final bool isDefault;

  const PaymentMethodModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.type,
    this.isDefault = false,
  });

  Color get brandColor {
    switch (type) {
      case PaymentMethodType.mtnMobile:
        return const Color(0xFFFFCC00);
      case PaymentMethodType.airtelMoney:
        return const Color(0xFFE4002B);
      case PaymentMethodType.stripe:
        return const Color(0xFF635BFF);
      case PaymentMethodType.visaCard:
        return const Color(0xFF1A1F71);
      case PaymentMethodType.mastercard:
        return const Color(0xFFEB001B);
    }
  }

  String get brandLabel {
    switch (type) {
      case PaymentMethodType.mtnMobile:
        return 'MTN';
      case PaymentMethodType.airtelMoney:
        return 'AIR';
      case PaymentMethodType.stripe:
        return 'STRIPE';
      case PaymentMethodType.visaCard:
        return 'VISA';
      case PaymentMethodType.mastercard:
        return 'MC';
    }
  }

  Color get labelTextColor {
    switch (type) {
      case PaymentMethodType.mtnMobile:
        return AppColors.textPrimary;
      default:
        return AppColors.textOnDark;
    }
  }

  bool get isAddNew => subtitle.toLowerCase().contains('add new');
}

/// Firestore document for `payments/{paymentId}`.
class PaymentRecord {
  final String id;
  final String patientId;
  final String providerId;
  final String? caregiverId;
  final String patientName;
  final String providerName;
  final String serviceType;
  final double amount;
  final String currency;
  final PaymentMethodType method;
  final TransactionStatus status;
  final String? appointmentId;
  final String? stripePaymentIntentId;
  final DateTime createdAt;
  final String month;

  const PaymentRecord({
    required this.id,
    required this.patientId,
    required this.providerId,
    this.caregiverId,
    required this.patientName,
    required this.providerName,
    required this.serviceType,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    required this.createdAt,
    required this.month,
    this.appointmentId,
    this.stripePaymentIntentId,
  });

  factory PaymentRecord.fromMap(Map<String, dynamic> map, String id) {
    return PaymentRecord(
      id: id,
      patientId: map['patientId']?.toString() ?? '',
      providerId: map['providerId']?.toString() ?? '',
      caregiverId: map['caregiverId']?.toString(),
      patientName: map['patientName']?.toString() ?? '',
      providerName: map['providerName']?.toString() ?? '',
      serviceType: map['serviceType']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      currency: map['currency']?.toString() ?? 'RWF',
      method: PaymentMethodType.values.firstWhere(
        (e) => e.name == map['method'],
        orElse: () => PaymentMethodType.stripe,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TransactionStatus.pending,
      ),
      appointmentId: map['appointmentId']?.toString(),
      stripePaymentIntentId: map['stripePaymentIntentId']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'] is int
                  ? map['createdAt'] as int
                  : int.tryParse(map['createdAt'].toString()) ?? 0,
            )
          : DateTime.now(),
      month: map['month']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'providerId': providerId,
        if (caregiverId != null) 'caregiverId': caregiverId,
        'patientName': patientName,
        'providerName': providerName,
        'serviceType': serviceType,
        'amount': amount,
        'currency': currency,
        'method': method.name,
        'status': status.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'month': month,
        if (appointmentId != null) 'appointmentId': appointmentId,
        if (stripePaymentIntentId != null)
          'stripePaymentIntentId': stripePaymentIntentId,
      };
}

class TransactionModel {
  final String id;
  final String providerName;
  final String date;
  final double amount;
  final String currency;
  final PaymentMethodType method;
  final TransactionStatus status;
  final String month;

  const TransactionModel({
    required this.id,
    required this.providerName,
    required this.date,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    required this.month,
  });

  factory TransactionModel.fromPayment(PaymentRecord p) {
    final h = p.createdAt.hour > 12
        ? p.createdAt.hour - 12
        : (p.createdAt.hour == 0 ? 12 : p.createdAt.hour);
    final period = p.createdAt.hour >= 12 ? 'PM' : 'AM';
    final min = p.createdAt.minute.toString().padLeft(2, '0');
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final date =
        '${p.createdAt.day} ${months[p.createdAt.month - 1]} ${p.createdAt.year}, $h:$min $period';

    return TransactionModel(
      id: p.id,
      providerName: p.providerName,
      date: date,
      amount: -p.amount.abs(),
      currency: p.currency,
      method: p.method,
      status: p.status,
      month: p.month,
    );
  }

  String get formattedAmount {
    final sign = amount < 0 ? '-' : '+';
    final abs = amount.abs().toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$sign$abs\n$currency';
  }

  Color get amountColor {
    if (status == TransactionStatus.failed) return AppColors.danger;
    return amount < 0 ? AppColors.textPrimary : AppColors.success;
  }

  Color get brandColor {
    switch (method) {
      case PaymentMethodType.mtnMobile:
        return const Color(0xFFFFCC00);
      case PaymentMethodType.airtelMoney:
        return const Color(0xFFE4002B);
      case PaymentMethodType.stripe:
        return const Color(0xFF635BFF);
      case PaymentMethodType.visaCard:
        return const Color(0xFF1A1F71);
      case PaymentMethodType.mastercard:
        return const Color(0xFFEB001B);
    }
  }

  Color get brandColorForFailed => const Color(0xFFE53935);

  String get brandLabel {
    if (status == TransactionStatus.failed) return '✕';
    switch (method) {
      case PaymentMethodType.mtnMobile:
        return 'MTN';
      case PaymentMethodType.airtelMoney:
        return 'AIR';
      case PaymentMethodType.stripe:
        return '✦';
      case PaymentMethodType.visaCard:
        return 'VISA';
      case PaymentMethodType.mastercard:
        return 'MC';
    }
  }

  Color get labelColor {
    switch (method) {
      case PaymentMethodType.mtnMobile:
        return AppColors.textPrimary;
      default:
        return Colors.white;
    }
  }

  String get methodName {
    switch (method) {
      case PaymentMethodType.mtnMobile:
        return 'MTN MoMo';
      case PaymentMethodType.airtelMoney:
        return 'Airtel Money';
      case PaymentMethodType.stripe:
        return 'Stripe';
      case PaymentMethodType.visaCard:
        return 'Visa Card';
      case PaymentMethodType.mastercard:
        return 'Mastercard';
    }
  }
}
