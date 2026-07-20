import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

// Firebase Cloud Messaging HTTP v1 project ID.
const String _fcmProjectId = 'ramma-d8d30';

class PushNotificationService {
  static String? _accessToken;

  /// Sends a push notification to a single target user.
  ///
  /// [userID] is the Firestore document id of the *recipient* (not the
  /// currently signed-in user). The recipient's FCM token is read from their
  /// user document and the message is delivered directly to that device.
  ///
  /// [data] carries key/value pairs (e.g. conversationId, roomId) used by the
  /// client to open the correct screen when the notification is tapped.
  static Future<void> sendPushNotification({
    required String userID,
    required String title,
    String? type,
    required String body,
    Map<String, String>? data,
    // When false the push is data-only (no auto-shown system
    // notification). Used for calls so our own full-screen ringing call
    // notification is the single, authoritative incoming-call UI.
    bool showSystemNotification = true,
  }) async {
    // Don't notify yourself (e.g. on your own device).
    if (userID == FirebaseAuth.instance.currentUser?.uid) {
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .get();

    final fcmToken = userDoc.data()?['fcmToken'] as String?;
    if (fcmToken == null || fcmToken.isEmpty) {
      log('No FCM token for user $userID');
      return;
    }

    try {
      _accessToken = await _getAccessToken();

      final payload = <String, dynamic>{
        "token": fcmToken,
        if (showSystemNotification)
          "notification": {"body": body, "title": title},
        "android": {
          "priority": "high",
          "notification": showSystemNotification
              ? {"channel_id": "rambaa_messages"}
              : {"channel_id": "rambaa_calls"},
        },
        "apns": {
          "payload": {
            "aps": showSystemNotification
                ? {"sound": "default", "content-available": 1}
                : {"content-available": 1},
          },
          if (!showSystemNotification)
            "headers": {"apns-priority": "10"},
        },
        "data": <String, String>{
          "type": type ?? "general",
          ...?data,
        },
      };

      final response = await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$_fcmProjectId/messages:send',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode(<String, dynamic>{"message": payload}),
      );

      if (response.statusCode == 200) {
        log('Push sent to $userID');
      } else {
        log('Push failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      log('Push error: $e');
    }
  }

  static Future<void> sendPushNotificationToAllUsers({
    required String title,
    required String body,
    String? imageURL,
  }) async {
    try {
      _accessToken = await _getAccessToken();

      final response = await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$_fcmProjectId/messages:send',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          "message": {
            "topic": "all_users",
            "notification": {"title": title, "body": body, "image": imageURL},
            "data": {
              "type": "general",
              "screen": "home",
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        log('Broadcast sent to all_users');
      } else {
        log('Broadcast failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      log('Broadcast error: $e');
    }
  }

  static Future<String> _getAccessToken() async {
    final serviceAccountJson =
        await rootBundle.loadString('assets/service_account_key.json');
    final serviceAccount = json.decode(serviceAccountJson);

    final accountCredentials =
        ServiceAccountCredentials.fromJson(serviceAccount);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client =
        await clientViaServiceAccount(accountCredentials, scopes);

    final authHeaders = client.credentials.accessToken;
    client.close();
    return authHeaders.data;
  }
}
