import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../controllers/auth_controllers/auth_controller.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import 'call_service.dart';
import 'local_notification.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['type'] == 'call') {
    return;
  } else if (message.notification == null) {
    await LocalNotificationsService.showLocalNotification(message);
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await LocalNotificationsService.initializeLocalNotifications();
    LocalNotificationsService.onNotificationTap = _navigate;

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedApp);
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _onOpenedApp(initial);

    _initialized = true;
  }

  void _onForegroundMessage(RemoteMessage message) {
    // Still show a local banner for calls so users can open chat/join.
    LocalNotificationsService.showLocalNotification(message);
  }

  void _onOpenedApp(RemoteMessage message) {
    _navigate(message.data);
  }

  void _navigate(Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? 'chat';
    final screen = data['screen']?.toString();
    final authReady = Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().user.value != null;
    if (!authReady) return;

    final user = Get.find<AuthController>().user.value!;

    if (type == 'call') {
      final roomId = data['roomId']?.toString() ?? '';
      if (roomId.isNotEmpty) {
        if (!Get.isRegistered<CallService>()) {
          Get.put(CallService(), permanent: true);
        }
        CallService.to.joinCall(
          roomId: roomId,
          userId: user.id,
          userName: user.name,
          remoteUserId:
              data['remoteUserId']?.toString() ?? data['participantId']?.toString() ?? '',
          calleeName: data['remoteUserName']?.toString() ??
              data['participantName']?.toString(),
          callType: data['callType']?.toString() ?? 'video',
        );
        return;
      }
      if ((data['conversationId']?.toString() ?? '').isNotEmpty) {
        Get.toNamed(
          AppRoutes.chat,
          arguments: ConversationModel(
            id: data['conversationId'].toString(),
            participantId: data['participantId']?.toString() ?? '',
            participantName: data['participantName']?.toString() ?? '',
            participantSpecialty: '',
            type: ConversationType.doctor,
            lastMessage: 'Incoming call',
            lastMessageTime: DateTime.now(),
          ),
        );
      }
      return;
    }

    if (type == 'appointment' || screen == 'appointments') {
      Get.toNamed(AppRoutes.appointments);
      return;
    }

    if (screen == 'home') {
      final role = user.role;
      switch (role) {
        case UserRole.provider:
          Get.toNamed(AppRoutes.providerDashboard);
          break;
        case UserRole.caregiver:
          Get.toNamed(AppRoutes.caregiverDashboard);
          break;
        case UserRole.home:
          Get.toNamed(AppRoutes.providerDashboard);
          break;
        default:
          Get.toNamed(AppRoutes.patientDashboard);
          break;
      }
      return;
    }

    final conversation = ConversationModel(
      id: data['conversationId']?.toString() ?? '',
      participantId: data['participantId']?.toString() ?? '',
      participantName: data['participantName']?.toString() ?? '',
      participantSpecialty: '',
      type: ConversationType.doctor,
      lastMessage: data['body']?.toString() ?? '',
      lastMessageTime: DateTime.now(),
    );
    Get.toNamed(AppRoutes.chat, arguments: conversation);
  }
}
