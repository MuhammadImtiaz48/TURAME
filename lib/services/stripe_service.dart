import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/stripe_config.dart';

class StripeService extends GetxService {
  static StripeService get to => Get.find<StripeService>();

  static const _paymentIntentsUrl =
      'https://api.stripe.com/v1/payment_intents';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    if (!StripeConfig.isConfigured) {
      debugPrint('Stripe keys not configured');
      return;
    }
    Stripe.publishableKey = StripeConfig.publishableKey;
    Stripe.merchantIdentifier = 'merchant.com.ramba';
    await Stripe.instance.applySettings();
    _initialized = true;
  }

  /// Charges [amount] (major units, e.g. RWF 5500) via Stripe Payment Sheet.
  /// Creates the PaymentIntent directly against the Stripe API (no Cloud Function).
  Future<String> pay({
    required double amount,
    required String currency,
    Map<String, String>? metadata,
  }) async {
    if (!StripeConfig.isConfigured) {
      throw Exception('Stripe keys are not configured.');
    }
    if (!_initialized) await init();

    // RWF is zero-decimal; Stripe expects the amount in the smallest unit.
    final stripeAmount = amount.round();
    if (stripeAmount < 1) {
      throw Exception('Invalid payment amount');
    }

    final intent = await _createPaymentIntent(
      amount: stripeAmount,
      currency: currency.toLowerCase(),
      metadata: metadata ?? {},
    );

    final clientSecret = intent['client_secret'] as String?;
    final paymentIntentId = intent['id'] as String?;

    if (clientSecret == null || clientSecret.isEmpty) {
      throw Exception('Missing Stripe client secret');
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: StripeConfig.merchantDisplayName,
        style: ThemeMode.light,
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    return paymentIntentId ?? '';
  }

  Future<Map<String, dynamic>> _createPaymentIntent({
    required int amount,
    required String currency,
    required Map<String, String> metadata,
  }) async {
    final body = <String, String>{
      'amount': amount.toString(),
      'currency': currency,
      'automatic_payment_methods[enabled]': 'true',
    };

    var i = 0;
    for (final entry in metadata.entries) {
      body['metadata[${entry.key}]'] = entry.value;
      i++;
      if (i > 20) break;
    }

    final response = await http.post(
      Uri.parse(_paymentIntentsUrl),
      headers: {
        'Authorization': 'Bearer ${StripeConfig.secretKey}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = data['error'] as Map<String, dynamic>?;
      throw Exception(
        error?['message']?.toString() ??
            'Stripe error (${response.statusCode})',
      );
    }

    return data;
  }
}
