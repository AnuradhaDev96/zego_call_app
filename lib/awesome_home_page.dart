import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'local_notification_controller.dart';
import 'message_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class AwesomeHomePage extends StatefulWidget {
  const AwesomeHomePage({super.key});

  @override
  State<AwesomeHomePage> createState() => _AwesomeHomePageState();
}

class _AwesomeHomePageState extends State<AwesomeHomePage> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String? title = message.notification?.title;
      String? body = message.notification?.body;

      AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 7501,
            channelKey: "call_channel",
            color: Colors.white,
            title: title,
            body: body,
            category: NotificationCategory.Call,
            fullScreenIntent: true,
            autoDismissible: false,
            backgroundColor: Colors.orange,
          ),
          actionButtons: [
            NotificationActionButton(key: "ACCEPT", label: "Accept Call", color: Colors.green, autoDismissible: true),
            NotificationActionButton(key: "REJECT", label: "Reject Call", color: Colors.red, autoDismissible: true),
          ]);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Communicator"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Welcome to communicator app",
            ),
            const SizedBox(height: 10.0),
            ElevatedButton.icon(
              onPressed: () async {
                String? token = await FirebaseMessaging.instance.getToken();
                print("Call token: $token");
              },
              icon: const Icon(Icons.token),
              label: const Text("Get token"),
            ),
            ElevatedButton.icon(
              onPressed: () => sendPushNotification(),
              icon: const Icon(Icons.send),
              label: const Text("Send push notification"),
            ),
          ],
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Row(
      //     children: [
      //       ElevatedButton.icon(
      //         icon: const Icon(Icons.send),
      //         label: const Text("Send"),
      //         onPressed: () {},
      //       )
      //     ],
      //   ),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendNotification() {
    flutterLocalNotificationsPlugin.show(
      0,
      "Testing notification",
      "Testing information message",
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

  Future<void> sendPushNotification() async {
    var messageKey = "AAAAeKB_HWU:APA91bH7idg4Qrt8j-dgi8kaIsYYnF6VI6qa2_Hr5cCwvS6jSnzwSBXLqiRSkV1fiUSVtrrgTPb98fQ4O76BT64ib46UGoKOJx9MPItv67kE1qkBdJ2_ZHIezrmh76nngGAJrjfNbJ8S";
    try {
      http.Response response = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$messageKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': "Call from Friend",
              'title': 'Call Center 2',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '15',
              'status': 'done'
            },
            'to': "dh7ZZFk7QgSZ2NdLFan1fU:APA91bGis_E94pn1DmxVGqANFWxD-Jgl55nWqUwcxNY2fdAoBVuMHLfqiO7YBYy1rvwB8F9eKQchuzBmqolroCSaS9PtumxLaRh0BuPAxR-pY6CDRx6JqTJOsP8XnXw-4ltTZBiSPyxw",
            // 'token': authorizedSupplierTokenId
          },
        ),
      );
      response;
    } catch (e) {
      e;
    }
  }
}