import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'common/statics.dart';
import 'local_notification_controller.dart';
import 'services/firebase_service.dart';

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
        channelKey: "basic_channel",
        title: title,
        body: body,
        category: NotificationCategory.Call,
        fullScreenIntent: true,
        autoDismissible: false,
        backgroundColor: Colors.amber,
      ),
      actionButtons: [
        NotificationActionButton(
          key: "ACCEPT",
          label: "Accept Call",
          color: const Color(0xFF83A980),
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: "REJECT",
          label: "Reject Call",
          color: const Color(0xFFF17474),
          autoDismissible: true,
        ),
      ],
    );

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        await LocalNotificationController.onActionReceivedMethod(receivedAction);
      },
      onNotificationCreatedMethod: (ReceivedNotification receivedNotification) async {
        await LocalNotificationController.onNotificationCreatedMethod(receivedNotification);
      },
      onNotificationDisplayedMethod: (ReceivedNotification receivedNotification) async {
        await LocalNotificationController.onNotificationDisplayedMethod(receivedNotification);
      },
      onDismissActionReceivedMethod: (ReceivedAction receivedAction) async {
        await LocalNotificationController.onDismissActionReceivedMethod(receivedAction);
      },
    );
  }

  static Future<void> sendPushNotification(String? receiverToken) async {
    print("Receiver firebase user token: $receiverToken");
    var currentUser = await FirebaseService.currentUser;

    try {
      http.Response response = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=${Statics.fcmKey}',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': "Incoming call...",
              'title': '${currentUser?.name}',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '15',
              'status': 'done'
            },
            'to': receiverToken,
            // 'token': authorizedSupplierTokenId
          },
        ),
      );
      response;
    } catch (e) {
      e;
    }
  }

  // static void showLocalNotification() {
  //   flutterLocalNotificationsPlugin.show(
  //     0,
  //     "Testing notification",
  //     "Testing information message",
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         MessageHandler.channel.id,
  //         MessageHandler.channel.name,
  //         channelDescription: MessageHandler.channel.description,
  //         color: Colors.blue,
  //         playSound: true,
  //         icon: "@mipmap/ic_launcher",
  //
  //       ),
  //     ),
  //   );
  // }
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