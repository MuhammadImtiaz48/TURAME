import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class LocalNotificationsService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const channelID = 'rambaa_messages';

  // Invoked when a foreground notification (or its action) is tapped.
  // The argument is the `data` payload of the received FCM message.
  static void Function(Map<String, dynamic> data)? onNotificationTap;

  //INITIALIZE LOCAL NOTIFICATIONS
  static Future<void> initializeLocalNotifications() async {
    print("initializing local notifications");
    var androidInitialize = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    var iosInitialize = const DarwinInitializationSettings();
    var initializeSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iosInitialize,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializeSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || onNotificationTap == null) return;
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          onNotificationTap!(data);
        } catch (_) {
          // Ignore malformed payloads.
        }
      },
    );
    await requestNotificationPermissions();
  }

  //PERMISSION FOR NOTIFICATIONS
  static Future<void> requestNotificationPermissions() async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      channelID,
      channelID,
      playSound: true,
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> showLocalNotification(RemoteMessage message) async {
    try {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        bool isImgNotification = false;
        String largeIconPath = '';
        String bigPicturePath = '';
        String? url;

        if (Platform.isAndroid) {
          url = message.notification?.android?.imageUrl;
        } else {
          url = message.notification?.apple?.imageUrl;
        }

        isImgNotification = url != null;
        BigPictureStyleInformation? bigPictureStyleInformation;
        // //log(notification.apple?.imageUrl ?? "NOT IMAGE");
        if (isImgNotification) {
          final img = await loadImageAndConvertToBase64(url);
          bigPictureStyleInformation = BigPictureStyleInformation(
            ByteArrayAndroidBitmap.fromBase64String(base64Encode(img)),
            hideExpandedLargeIcon: true,
            largeIcon: ByteArrayAndroidBitmap.fromBase64String(
              base64Encode(img),
            ),
          );

          largeIconPath = await _downloadAndSaveFile(
            url,
            'largeIcon',
            Platform.isIOS,
          );
          bigPicturePath = await _downloadAndSaveFile(
            url,
            'bigPicture',
            Platform.isIOS,
          );
        }

        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channelID,
              channelID,
              icon: 'launch_background',
              channelDescription: 'App notifications',
              importance: Importance.max,
              priority: Priority.max,
              largeIcon: url == null
                  ? null
                  : FilePathAndroidBitmap(largeIconPath),
              styleInformation:
                  url == null ? null : bigPictureStyleInformation,
            ),
            iOS: url == null
                ? const DarwinNotificationDetails()
                : DarwinNotificationDetails(
                    attachments: [DarwinNotificationAttachment(bigPicturePath)],
                  ),
          ),
          payload: jsonEncode(message.data),
        );
      } else {}
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<List<int>> loadImageAndConvertToBase64(String imageUrl) async {
    http.Response response = await http.get(Uri.parse(imageUrl));
    List<int> imageData = response.bodyBytes;
    return imageData;
  }

  static Future<String> _downloadAndSaveFile(
    String url,
    String fileName,
    bool isIOS,
  ) async {
    final Directory? directory = isIOS
        ? await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();
    final String filePath = '${directory!.path}/$fileName.png';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> showNotification(String title, String body) async {
    var androidDetails = const AndroidNotificationDetails(
      "channel_id",
      "channel_name",
      importance: Importance.max,
      priority: Priority.max,
    );
    var iosDetails = const DarwinNotificationDetails();
    var generalNotificationsDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    Random rand = Random();
    await flutterLocalNotificationsPlugin.show(
      rand.nextInt(999),
      title,
      body,
      generalNotificationsDetails,
    );
    // await flutterLocalNotificationsPlugin.cancel(7663135);
  }
}
