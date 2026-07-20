import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../models/payment_model.dart';
import '../models/privacy_setting_model.dart';
import '../models/support_ticket_model.dart';
import '../models/user_model.dart';
import '../models/patient_model.dart';
import '../models/provider_model.dart';
import '../models/caregiver_profile_model.dart';
import '../models/caregiver_model.dart';
import '../models/withdrawal_model.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String conversationIdFor(String a, String b) {
    final ids = [a, b]..sort();
    return 'conv_${ids.join('_')}';
  }

  static String monthLabel(DateTime dt) {
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  // ── Users ───────────────────────────────────────────────────

  static Future<List<PatientModel>> getPatients() async {
    try {
      final query =
          await _db.collection('users').where('role', isEqualTo: 'patient').get();
      return query.docs
          .map((doc) => PatientModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> updatePatient(PatientModel patient) async {
    await _db.collection('users').doc(patient.id).update(patient.toMap());
  }

  static Future<PatientModel?> getPatientById(String id) async {
    try {
      final doc = await _db.collection('users').doc(id).get();
      if (doc.exists) {
        return PatientModel.fromMap({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<ProviderModel>> getProviders() async {
    try {
      final query =
          await _db.collection('users').where('role', isEqualTo: 'provider').get();
      return query.docs
          .map((doc) => ProviderModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Stream<List<ProviderModel>> getProvidersStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'provider')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ProviderModel.fromMap({'id': doc.id, ...doc.data()}))
              .toList(),
        );
  }

  static Stream<List<PatientModel>> getPatientsStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => PatientModel.fromMap({'id': doc.id, ...doc.data()}))
              .toList(),
        );
  }

  static Future<String?> getUserImageUrl(String userId) async {
    if (userId.isEmpty) return null;
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        final url = data?['imageUrl'];
        if (url is String && url.isNotEmpty) return url;
      }
    } catch (_) {}
    return null;
  }

  static Future<ProviderModel?> getProviderById(String providerId) async {
    try {
      final doc = await _db.collection('users').doc(providerId).get();
      if (doc.exists) {
        return ProviderModel.fromMap({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateProvider(ProviderModel provider) async {
    await _db.collection('users').doc(provider.id).update(provider.toMap());
  }

  static Future<List<CaregiverModel>> getCaregivers() async {
    try {
      final query = await _db.collection('users').where('role', isEqualTo: 'caregiver').get();
      return query.docs.map((doc) => CaregiverModel.fromMap({'id': doc.id, ...doc.data()})).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<CaregiverProfileModel?> getCaregiverById(String caregiverId) async {
    try {
      final doc = await _db.collection('users').doc(caregiverId).get();
      if (doc.exists) {
        return CaregiverProfileModel.fromMap({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateCaregiver(CaregiverProfileModel caregiver) async {
    await _db.collection('users').doc(caregiver.id).update(caregiver.toMap());
  }

  static Future<List<Map<String, dynamic>>> getAppointmentsByCaregiver(
      String caregiverId) async {
    try {
      final query = await _db
          .collection('appointments')
          .where('caregiverId', isEqualTo: caregiverId)
          .orderBy('dateTime')
          .get();
      return query.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      return [];
    }
  }

  /// Live stream of a caregiver's appointments so newly booked clients
  /// appear on the dashboard without a manual refresh.
  static Stream<List<Map<String, dynamic>>> appointmentsByCaregiverStream(
      String caregiverId) {
    return _db
        .collection('appointments')
        .where('caregiverId', isEqualTo: caregiverId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      return list;
    });
  }

  static Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap({'id': uid, ...doc.data()!});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isNotificationsEnabled(String uid) async {
    try {
      final user = await getUserData(uid);
      return user?.notificationsEnabled ?? true;
    } catch (_) {
      return true;
    }
  }

  static Future<void> createUser(UserModel user) async {
    await _db
        .collection('users')
        .doc(user.id)
        .set(user.toMap(), SetOptions(merge: true));
  }

  static Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.id).update(user.toMap());
  }

  static Future<String?> getFcmToken() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _db.collection('users').doc(uid).update({'fcmToken': token});
    } catch (e) {
      // best-effort
    }
  }

  static Future<void> saveFcmTokenForUser(String uid) async {
    final token = await getFcmToken();
    if (token != null && token.isNotEmpty) {
      await updateFcmToken(uid, token);
    }
  }

  static Future<void> updateUserRole(String uid, UserRole role) async {
    await _db.collection('users').doc(uid).update({'role': role.name});
  }

  static Future<void> sendOtp(String phone) async {
    await _db.collection('otps').doc(phone).set({
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> verifyOtp(String phone, String otp) async {
    final query = await _db
        .collection('otps')
        .where('phone', isEqualTo: phone)
        .where('otp', isEqualTo: otp)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid OTP');
    }
  }

  // ── Appointments ────────────────────────────────────────────

  static Future<String> createAppointment(Map<String, dynamic> data) async {
    final doc = _db.collection('appointments').doc();
    final payload = {...data, 'id': doc.id};
    await doc.set(payload);
    return doc.id;
  }

  static Future<List<Map<String, dynamic>>> getAppointmentsByProvider(
      String providerId) async {
    try {
      final query = await _db
          .collection('appointments')
          .where('providerId', isEqualTo: providerId)
          .get();
      return query.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAppointmentsByPatient(
      String patientId) async {
    try {
      final query = await _db
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .get();
      return query.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> updateAppointmentStatus(String id, String status) async {
    await _db.collection('appointments').doc(id).update({'status': status});
  }

  // ── Messages ────────────────────────────────────────────────

  static Stream<List<MessageModel>> getMessagesStream(
    String conversationId,
    String userId,
  ) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => MessageModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  static Future<void> sendMessage(
    String conversationId,
    String senderId,
    String receiverId,
    MessageModel message, {
    String? senderName,
    String? receiverName,
    String? senderSpecialty,
    String? receiverSpecialty,
  }) async {
    final batch = _db.batch();
    final now = message.timestamp.millisecondsSinceEpoch;

    final sides = <String, Map<String, String>>{
      senderId: {
        'participantId': receiverId,
        'participantName': receiverName ?? '',
        'specialty': receiverSpecialty ?? '',
      },
      receiverId: {
        'participantId': senderId,
        'participantName': senderName ?? '',
        'specialty': senderSpecialty ?? '',
      },
    };

    for (final entry in sides.entries) {
      final uid = entry.key;
      final meta = entry.value;
      final convRef = _db
          .collection('users')
          .doc(uid)
          .collection('conversations')
          .doc(conversationId);
      final msgRef = convRef.collection('messages').doc(message.id);

      batch.set(msgRef, message.toMap());
      batch.set(
        convRef,
        {
          'participantId': meta['participantId'],
          'participantName': meta['participantName'],
          'participantSpecialty': meta['specialty'],
          'type': ConversationType.doctor.name,
          'lastMessage': message.content,
          'lastMessageTime': now,
          'unreadCount': uid == receiverId ? FieldValue.increment(1) : 0,
          'isOnline': false,
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  // ── Payments ────────────────────────────────────────────────

  static Future<String> createPayment(PaymentRecord payment) async {
    final doc = payment.id.isEmpty
        ? _db.collection('payments').doc()
        : _db.collection('payments').doc(payment.id);
    final id = doc.id;
    await doc.set({...payment.toMap(), 'id': id});
    return id;
  }

  static Future<List<PaymentRecord>> getPaymentsByPatient(String patientId) async {
    try {
      final query = await _db
          .collection('payments')
          .where('patientId', isEqualTo: patientId)
          .get();
      final list = query.docs
          .map((d) => PaymentRecord.fromMap(d.data(), d.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      return [];
    }
  }

  static Future<List<PaymentRecord>> getPaymentsByProvider(
      String providerId) async {
    try {
      final query = await _db
          .collection('payments')
          .where('providerId', isEqualTo: providerId)
          .get();
      final list = query.docs
          .map((d) => PaymentRecord.fromMap(d.data(), d.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      return [];
    }
  }

  static Stream<List<PaymentRecord>> paymentsByProviderStream(String providerId) {
    return _db
        .collection('payments')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => PaymentRecord.fromMap(d.data(), d.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  static Stream<List<PaymentRecord>> paymentsByCaregiverStream(String caregiverId) {
    // Caregiver bookings store the caregiver's id in BOTH `caregiverId` and
    // `providerId`. Older payments may only have `providerId`, so match either
    // field and merge the results so all earnings show up.
    final byCaregiver = _db
        .collection('payments')
        .where('caregiverId', isEqualTo: caregiverId)
        .snapshots();
    final byProvider = _db
        .collection('payments')
        .where('providerId', isEqualTo: caregiverId)
        .snapshots();

    return Rx.combineLatest2<QuerySnapshot<Map<String, dynamic>>,
        QuerySnapshot<Map<String, dynamic>>, List<PaymentRecord>>(
      byCaregiver,
      byProvider,
      (a, b) {
        final merged = <String, PaymentRecord>{};
        for (final d in a.docs) {
          merged[d.id] = PaymentRecord.fromMap(d.data(), d.id);
        }
        for (final d in b.docs) {
          merged[d.id] = PaymentRecord.fromMap(d.data(), d.id);
        }
        final list = merged.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      },
    );
  }

  // ── Notifications ───────────────────────────────────────────

  static Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    String category = 'General',
    Map<String, String> data = const {},
  }) async {
    final doc =
        _db.collection('users').doc(userId).collection('notifications').doc();
    final notification = NotificationModel(
      id: doc.id,
      title: title,
      message: message,
      type: type,
      category: category,
      createdAt: DateTime.now(),
      data: data,
    );
    await doc.set(notification.toMap());
  }

  static Stream<List<NotificationModel>> notificationsStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => NotificationModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  static Future<void> markNotificationRead(
      String userId, String notificationId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  static Future<void> markAllNotificationsRead(String userId) async {
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  static Future<void> deleteNotification(
      String userId, String notificationId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  static Future<void> deleteAllNotifications(String userId) async {
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  static Future<String> createWithdrawal(WithdrawalRecord withdrawal) async {
    final doc = _db.collection('withdrawals').doc();
    final id = doc.id;
    await doc.set({...withdrawal.toMap(), 'id': id});
    return id;
  }

  static Stream<List<WithdrawalRecord>> withdrawalsByProviderStream(String providerId) {
    return _db
        .collection('withdrawals')
        .where('userId', isEqualTo: providerId)
        .where('userRole', isEqualTo: 'provider')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => WithdrawalRecord.fromMap(d.data(), d.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  static Stream<List<WithdrawalRecord>> withdrawalsByCaregiverStream(String caregiverId) {
    return _db
        .collection('withdrawals')
        .where('userId', isEqualTo: caregiverId)
        .where('userRole', isEqualTo: 'caregiver')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => WithdrawalRecord.fromMap(d.data(), d.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ── Privacy Settings ────────────────────────────────────────

  static Future<PrivacySettingModel?> getPrivacySettings(String userId) async {
    try {
      final doc = await _db.collection('privacy_settings').doc(userId).get();
      if (doc.exists) {
        return PrivacySettingModel.fromMap({'userId': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Stream<PrivacySettingModel?> privacySettingsStream(String userId) {
    return _db
        .collection('privacy_settings')
        .doc(userId)
        .snapshots()
        .map((snap) {
      if (snap.exists) {
        return PrivacySettingModel.fromMap({'userId': snap.id, ...snap.data()!});
      }
      return null;
    });
  }

  static Future<void> savePrivacySettings(PrivacySettingModel settings) async {
    await _db
        .collection('privacy_settings')
        .doc(settings.userId)
        .set(settings.toMap(), SetOptions(merge: true));
  }

  static Future<void> updatePrivacySetting(String userId, Map<String, dynamic> data) async {
    await _db.collection('privacy_settings').doc(userId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Support Tickets ─────────────────────────────────────────

  static Future<String> createSupportTicket(SupportTicketModel ticket) async {
    final doc = _db.collection('support_tickets').doc();
    final id = doc.id;
    final payload = {...ticket.toMap(), 'id': id};
    await doc.set(payload);
    return id;
  }

  static Future<List<SupportTicketModel>> getSupportTicketsByUser(String userId) async {
    try {
      final query = await _db
          .collection('support_tickets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return query.docs
          .map((d) => SupportTicketModel.fromMap(d.data(), d.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Stream<List<SupportTicketModel>> supportTicketsByUserStream(String userId) {
    return _db
        .collection('support_tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => SupportTicketModel.fromMap(d.data(), d.id))
          .toList();
    });
  }

  static Future<SupportTicketModel?> getSupportTicketById(String ticketId) async {
    try {
      final doc = await _db.collection('support_tickets').doc(ticketId).get();
      if (doc.exists) {
        return SupportTicketModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateSupportTicketStatus(
      String ticketId, SupportTicketStatus status) async {
    await _db.collection('support_tickets').doc(ticketId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> addSupportTicketResponse(
      String ticketId, SupportTicketResponse response) async {
    await _db.collection('support_tickets').doc(ticketId).update({
      'responses': FieldValue.arrayUnion([response.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'inProgress',
    });
  }
}
