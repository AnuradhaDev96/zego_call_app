import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';

class MessageHandler {
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Importance notifications are screened using this channel',
    importance: Importance.high,
    playSound: true,
  );

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    String? title = message.notification?.title;
    String? body = message.notification?.body;

    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 7501,
      channelKey: "call_channel",
          title: title,
          body: body,
          category: NotificationCategory.Call,
          fullScreenIntent: true,
          autoDismissible: false,
          backgroundColor: Colors.amber,
    ),
    actionButtons: [
      NotificationActionButton(key: "ACCEPT", label: "Accept Call", color: Colors.green, autoDismissible: true),
      NotificationActionButton(key: "REJECT", label: "Reject Call", color: Colors.red, autoDismissible: true),
    ]);
  }
}

class TempClass{
  void initStateActions(BuildContext context) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("New onMessage event was published");
      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;

      if (notification != null && androidNotification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              MessageHandler.channel.id,
              MessageHandler.channel.name,
              channelDescription: MessageHandler.channel.description,
              color: Colors.blue,
              playSound: true,
              icon: "@mipmap/ic_launcher",
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("New onMessageOpenedApp event was published");
      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;

      if (notification != null && androidNotification != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title ?? '-'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body ?? 'N/A'),
                    ],
                  ),
                ),
              );
            });
      }
    });
  }
}