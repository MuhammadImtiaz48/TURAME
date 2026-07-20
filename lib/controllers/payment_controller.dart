import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/notification_model.dart';
import '../models/payment_model.dart';
import '../routes/app_routes.dart';
import '../services/firebase_service.dart';
import '../services/push_notification.dart';
import '../services/stripe_service.dart';
import 'appointment_controller.dart';
import 'auth_controllers/auth_controller.dart';

class PaymentController extends GetxController {
  final selectedMethodId = 'stripe'.obs;
  final isProcessing = false.obs;
  final selectedFilter = 'This Month'.obs;

  final Rx<OrderSummaryModel> order = const OrderSummaryModel(
    providerName: '',
    serviceType: '',
    consultationFee: 0,
    serviceFee: 0,
    currency: 'RWF',
  ).obs;

  /// Pending booking args from BookingSummaryScreen.
  Map<String, dynamic>? bookingArgs;

  final RxList<PaymentMethodModel> methods = <PaymentMethodModel>[
    PaymentMethodModel(
      id: 'stripe',
      name: 'Stripe (Card)',
      subtitle: 'Visa, Mastercard & more',
      type: PaymentMethodType.stripe,
      isDefault: true,
    ),
    PaymentMethodModel(
      id: 'mtn',
      name: 'MTN Mobile Money',
      subtitle: '+250 078 XXX XXX',
      type: PaymentMethodType.mtnMobile,
    ),
    PaymentMethodModel(
      id: 'airtel',
      name: 'Airtel Money',
      subtitle: '+250 073 XXX XXX',
      type: PaymentMethodType.airtelMoney,
    ),
  ].obs;

  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _hydrateFromArgs();
    loadTransactions();
  }

  void _hydrateFromArgs() {
    final args = Get.arguments;
    if (args is! Map<String, dynamic>) return;
    bookingArgs = args;

    final provider = args['provider'] as Map<String, dynamic>? ?? {};
    final service = args['service'];
    final consultation =
        (service?.price as num?)?.toDouble() ?? 5000.0;
    order.value = OrderSummaryModel(
      providerName: provider['name']?.toString() ?? '',
      serviceType: service?.name?.toString() ?? 'General Consultation',
      consultationFee: consultation,
      serviceFee: 500,
      currency: 'RWF',
    );
  }

  Future<void> loadTransactions() async {
    final uid = Get.find<AuthController>().user.value?.id ?? '';
    if (uid.isEmpty) return;
    try {
      final payments = await FirebaseService.getPaymentsByPatient(uid);
      transactions.assignAll(
        payments.map(TransactionModel.fromPayment).toList(),
      );
    } catch (_) {}
  }

  String get selectedMethodName {
    final m = methods.firstWhereOrNull((m) => m.id == selectedMethodId.value);
    return m?.name ?? 'Stripe';
  }

  PaymentMethodType get selectedMethodType {
    final m = methods.firstWhereOrNull((m) => m.id == selectedMethodId.value);
    return m?.type ?? PaymentMethodType.stripe;
  }

  String get transactionDate =>
      DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

  int get totalTransactions => transactions.length;

  String get totalAmount {
    final total = transactions
        .where((t) => t.status == TransactionStatus.success)
        .fold<double>(0, (sum, t) => sum + t.amount.abs());
    return 'RWF ${total.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        )}';
  }

  Map<String, List<TransactionModel>> get groupedTransactions {
    final Map<String, List<TransactionModel>> map = {};
    for (final tx in transactions) {
      map.putIfAbsent(tx.month, () => []).add(tx);
    }
    return map;
  }

  void selectMethod(String id) => selectedMethodId.value = id;

  void toggleFilter() {
    selectedFilter.value =
        selectedFilter.value == 'This Month' ? 'All Time' : 'This Month';
  }

  Future<void> processPayment() async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    try {
      final auth = Get.find<AuthController>();
      final patient = auth.user.value;
      if (patient == null) {
        throw Exception('Please sign in to continue');
      }

      final args = bookingArgs ??
          (Get.arguments is Map<String, dynamic>
              ? Get.arguments as Map<String, dynamic>
              : null);
      if (args == null) {
        throw Exception('Missing booking details');
      }

      final provider = args['provider'] as Map<String, dynamic>? ?? {};
      final providerId = provider['id']?.toString() ?? '';
      final providerName = provider['name']?.toString() ?? '';
      final providerRole = provider['role']?.toString() ?? 'provider';
      final isCaregiver = providerRole == 'caregiver';
      if (providerId.isEmpty) {
        throw Exception('Invalid provider');
      }

      String? stripePaymentIntentId;
      if (selectedMethodType == PaymentMethodType.stripe) {
        if (!Get.isRegistered<StripeService>()) {
          Get.put(StripeService(), permanent: true);
        }
        stripePaymentIntentId = await StripeService.to.pay(
          amount: order.value.total,
          currency: order.value.currency,
          metadata: {
            'patientId': patient.id,
            'providerId': providerId,
            'serviceType': order.value.serviceType,
          },
        );
      }

      final appointmentId = await _createAppointment(args, patient.id);
      final now = DateTime.now();
      final payment = PaymentRecord(
        id: '',
        patientId: patient.id,
        providerId: providerId,
        caregiverId: isCaregiver ? providerId : null,
        patientName: patient.name,
        providerName: providerName,
        serviceType: order.value.serviceType,
        amount: order.value.total,
        currency: order.value.currency,
        method: selectedMethodType,
        status: TransactionStatus.success,
        appointmentId: appointmentId,
        stripePaymentIntentId: stripePaymentIntentId,
        createdAt: now,
        month: FirebaseService.monthLabel(now),
      );
      await FirebaseService.createPayment(payment);

      await _notifyProviderOfBooking(
        providerId: providerId,
        patientName: patient.name,
        serviceType: order.value.serviceType,
        appointmentId: appointmentId,
        amount: order.value.formattedTotal,
      );

      await _notifyPaymentReceived(
        providerId: providerId,
        patientName: patient.name,
        serviceType: order.value.serviceType,
        amount: order.value.formattedTotal,
      );

      try {
        if (Get.isRegistered<AppointmentController>()) {
          Get.find<AppointmentController>().reload();
        }
      } catch (_) {}

      await loadTransactions();

      final bookingId =
          '#RMB-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';

      Get.offAllNamed(
        AppRoutes.bookingSuccess,
        arguments: {
          'provider': args['provider'],
          'service': args['service'],
          'date': args['date'],
          'time': args['time'],
          'total': order.value.total,
          'bookingId': bookingId,
          'appointmentId': appointmentId,
        },
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      // User cancelled Stripe sheet — don't show scary error.
      if (msg.toLowerCase().contains('canceled') ||
          msg.toLowerCase().contains('cancelled')) {
        return;
      }
      Get.snackbar(
        'Payment Failed',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<String> _createAppointment(
    Map<String, dynamic> args,
    String patientId,
  ) async {
    final provider = args['provider'] as Map<String, dynamic>? ?? {};
    final service = args['service'];
    final dateItem = args['date'];
    final time = (args['time'] as String?) ?? '09:00';
    final patient = Get.find<AuthController>().user.value;

    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    DateTime dateTime;
    try {
      final selectedDateTime = (dateItem as dynamic).dateTime as DateTime?;
      if (selectedDateTime != null) {
        dateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          hour,
          minute,
        );
      } else {
        final now = DateTime.now();
        dateTime = DateTime(now.year, now.month, now.day, hour, minute);
      }
    } catch (_) {
      final now = DateTime.now();
      dateTime = DateTime(now.year, now.month, now.day, hour, minute);
    }

    final svcName = service?.name ?? 'General Consultation';
    final callType = (args['callType'] as String?) ?? 'video';
    final duration = int.tryParse(
          (service?.duration ?? '30 min').replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        30;

    final role = provider['role'] ?? 'provider';
    final providerId = provider['id'] ?? '';
    return FirebaseService.createAppointment({
      'providerId': providerId,
      if (role == 'caregiver') 'caregiverId': providerId,
      'patientId': patientId,
      'patientName': patient?.name ?? '',
      if (role == 'caregiver') 'clientId': patientId,
      if (role == 'caregiver') 'clientName': patient?.name ?? '',
      'role': role,
      'providerName': provider['name'] ?? '',
      'avatarEmoji': provider['avatarEmoji'] ?? '👩‍⚕️',
      'imageUrl': provider['imageUrl'] ?? '',
      'reason': svcName,
      'specialty': provider['specialty'] ?? svcName,
      'type': callType,
      'dateTime': Timestamp.fromDate(dateTime),
      'durationMins': duration,
      'status': 'pending',
      'paymentStatus': 'paid',
      'paymentMethod': selectedMethodType.name,
    });
  }

  Future<void> _notifyProviderOfBooking({
    required String providerId,
    required String patientName,
    required String serviceType,
    required String appointmentId,
    required String amount,
  }) async {
    try {
      final enabled = await FirebaseService.isNotificationsEnabled(providerId);
      if (!enabled) return;

      await FirebaseService.createNotification(
        userId: providerId,
        title: 'New Booking Request',
        message:
            '$patientName booked $serviceType ($amount). Open appointments to confirm.',
        type: NotificationType.appointment,
        category: 'Appointments',
        data: {
          'appointmentId': appointmentId,
          'screen': 'appointments',
        },
      );

      await PushNotificationService.sendPushNotification(
        userID: providerId,
        type: 'appointment',
        title: 'New Booking Request',
        body: '$patientName booked $serviceType successfully.',
        data: {
          'appointmentId': appointmentId,
          'screen': 'appointments',
        },
      );
    } catch (_) {
      // Best-effort notifications.
    }
  }

  Future<void> _notifyPaymentReceived({
    required String providerId,
    required String patientName,
    required String serviceType,
    required String amount,
  }) async {
    try {
      final enabled = await FirebaseService.isNotificationsEnabled(providerId);
      if (!enabled) return;

      await FirebaseService.createNotification(
        userId: providerId,
        title: 'Payment Received',
        message: '$patientName paid $amount for $serviceType.',
        type: NotificationType.payment,
        category: 'Payments',
        data: {'amount': amount},
      );

      await PushNotificationService.sendPushNotification(
        userID: providerId,
        type: 'payment',
        title: 'Payment Received',
        body: '$patientName paid $amount for $serviceType.',
        data: {
          'amount': amount,
          'screen': 'earnings',
        },
      );
    } catch (_) {
      // Best-effort notifications.
    }
  }
}
