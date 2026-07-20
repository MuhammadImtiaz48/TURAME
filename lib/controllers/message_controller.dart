// FILE: lib/controllers/messages_controller.dart
//
// Conversations are built from ACTUAL appointments, not dummy data.
// Firestore paths:
//   conversations  → users/{uid}/conversations
//   messages       → users/{uid}/conversations/{convId}/messages

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../models/message_model.dart';
import '../models/appointment_model.dart';
import '../models/provider_appointment_model.dart';
import '../models/user_model.dart';
import '../controllers/auth_controllers/auth_controller.dart';
import '../services/firebase_service.dart';

String _conversationId(String a, String b) {
  final ids = [a, b]..sort();
  return 'conv_${ids.join('_')}';
}

class MessagesController extends GetxController {
  // ── State ─────────────────────────────────────────────────
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  StreamSubscription? _apptSub;

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    // Defer the load so isLoading/observables aren't mutated synchronously
    // while the (eagerly built) messages screen's Obx widgets are mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenConversations();
    });
  }

  @override
  void onClose() {
    _apptSub?.cancel();
    super.onClose();
  }

  // Live listener so a patient/client who books appears in the messages
  // list automatically (caregiver uses the appointments stream). Other
  // roles fall back to a one-time load.
  void _listenConversations() {
    final authCtrl = Get.find<AuthController>();
    final currentUser = authCtrl.user.value;
    if (currentUser == null) {
      isLoading.value = false;
      return;
    }

    if (currentUser.role == UserRole.caregiver) {
      isLoading.value = true;
      _apptSub?.cancel();
      _apptSub =
          FirebaseService.appointmentsByCaregiverStream(currentUser.id).listen(
        (maps) {
          _buildCaregiverConversations(currentUser.id, maps);
          isLoading.value = false;
        },
        onError: (_) {
          isLoading.value = false;
        },
      );
      return;
    }

    loadConversations();
  }

  void _buildCaregiverConversations(
      String caregiverId, List<Map<String, dynamic>> maps) {
    final List<ConversationModel> result = [];
    final seen = <String>{};

    for (final map in maps) {
      final appt = AppointmentModel.fromMap(map, map['id'] ?? '');
      if (appt.status == AppointmentStatus.cancelled) continue;
      final patientId = map['patientId']?.toString() ?? '';
      final patientName = map['patientName']?.toString() ??
          map['clientName']?.toString() ??
          '';
      if (patientId.isEmpty || seen.contains(patientId)) continue;
      seen.add(patientId);
      result.add(
        ConversationModel(
          id: _conversationId(caregiverId, patientId),
          participantId: patientId,
          participantName: patientName,
          participantSpecialty: appt.specialty,
          type: ConversationType.caregiver,
          lastMessage: '',
          lastMessageTime: appt.dateTime,
          isOnline: true,
          imageUrl: appt.imageUrl,
        ),
      );
    }

    result.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    conversations.value = result;
  }

  // ── Load ──────────────────────────────────────────────────
  // TODO (Firebase): replace with Firestore stream
  // FirebaseFirestore.instance
  //   .collection('users')
  //   .doc(currentUserId)
  //   .collection('conversations')
  //   .orderBy('lastMessageTime', descending: true)
  //   .snapshots()
  //   .listen((snap) {
  //     conversations.value = snap.docs
  //       .map((d) => ConversationModel.fromMap(d.data(), d.id))
  //       .toList();
  //   });

  Future<void> loadConversations() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 400));

    final authCtrl = Get.find<AuthController>();
    final currentUser = authCtrl.user.value;
    if (currentUser == null) {
      isLoading.value = false;
      return;
    }

    final List<ConversationModel> result = [];
    final seen = <String>{};

    switch (currentUser.role) {
      case UserRole.patient:
        final maps = await FirebaseService.getAppointmentsByPatient(currentUser.id);
        for (final map in maps) {
          final appt = AppointmentModel.fromMap(map, map['id'] ?? '');
          if (appt.status == AppointmentStatus.cancelled) continue;
          if (seen.contains(appt.providerId)) continue;
          seen.add(appt.providerId);
          result.add(
            ConversationModel(
              id: _conversationId(currentUser.id, appt.providerId),
              participantId: appt.providerId,
              participantName: appt.providerName,
              participantSpecialty: appt.specialty,
              type: ConversationType.doctor,
              lastMessage: '',
              lastMessageTime: appt.dateTime,
              isOnline: true,
              imageUrl: appt.imageUrl,
            ),
          );
        }
        break;

      case UserRole.provider:
      case UserRole.home:
        final maps = await FirebaseService.getAppointmentsByProvider(currentUser.id);
        for (final map in maps) {
          final appt = ProviderAppointmentModel.fromMap(map);
          if (appt.status == AppointmentStatus.cancelled) continue;
          if (seen.contains(appt.patientId)) continue;
          seen.add(appt.patientId);
          result.add(
            ConversationModel(
              id: _conversationId(currentUser.id, appt.patientId),
              participantId: appt.patientId,
              participantName: appt.patientName,
              participantSpecialty: appt.reason,
              type: ConversationType.doctor,
              lastMessage: '',
              lastMessageTime: appt.dateTime,
              isOnline: true,
            ),
          );
        }
        break;

      case UserRole.caregiver:
        final maps = await FirebaseService.getAppointmentsByCaregiver(currentUser.id);
        _buildCaregiverConversations(currentUser.id, maps);
        isLoading.value = false;
        return;
    }

    conversations.value = result;
    isLoading.value = false;
  }

  // ── Search ────────────────────────────────────────────────
  void onSearch(String query) => searchQuery.value = query.toLowerCase();

  List<ConversationModel> get filtered {
    if (searchQuery.value.isEmpty) return conversations;
    return conversations
        .where((c) =>
    c.participantName
        .toLowerCase()
        .contains(searchQuery.value) ||
        c.lastMessage.toLowerCase().contains(searchQuery.value))
        .toList();
  }

  // ── Helpers ───────────────────────────────────────────────
  String formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0) {
      final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '$h:$min $period';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dt.weekday - 1];
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}