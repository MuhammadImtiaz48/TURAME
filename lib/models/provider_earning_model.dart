import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'payment_model.dart';

class ProviderEarningModel {
  final String id;
  final String patientName;
  final String serviceType;
  final String date;
  final double amount;
  final String currency;
  final String month;
  final TransactionStatus status;
  final PaymentMethodType method;

  const ProviderEarningModel({
    required this.id,
    required this.patientName,
    required this.serviceType,
    required this.date,
    required this.amount,
    this.currency = 'RWF',
    required this.month,
    required this.status,
    required this.method,
  });

  factory ProviderEarningModel.fromPayment(PaymentRecord p) {
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

    return ProviderEarningModel(
      id: p.id,
      patientName: p.patientName,
      serviceType: p.serviceType,
      date: date,
      amount: p.amount,
      currency: p.currency,
      month: p.month,
      status: p.status,
      method: p.method,
    );
  }

  String get formattedAmount {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '+$formatted $currency';
  }

  Color get amountColor {
    if (status == TransactionStatus.failed) return AppColors.danger;
    return AppColors.healthGreen;
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
