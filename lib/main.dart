import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notifications_app/firebase_options.dart';
import 'package:http/http.dart' as http;

import 'local_notification_controller.dart';
import 'message_handler.dart';
import 'models/user_model.dart';
import 'services/firebase_service.dart';
import 'zego/call_invitation_page.dart';
import 'zego/login_page.dart';
import 'zego/user_card.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: "call_channel",
      channelName: "Call Channel",
      channelDescription: "Channel of calling",
      defaultColor: Colors.brown,
      ledColor: Colors.red,
      importance: NotificationImportance.Max,
      channelShowBadge: true,
      locked: true,
      defaultRingtoneType: DefaultRingtoneType.Ringtone,
    )
  ]);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(MessageHandler.firebaseMessagingBackgroundHandler);

  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(MessageHandler.channel);

  // await FirebaseMessaging.instance.subscribeToTopic('TopicToListen');

  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3C8339))),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: Column(
                  children: const [
                    CircularProgressIndicator(),
                    Text("Please wait we are authenticating."),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            return const DashboardPage();
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sam Caller"),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseService.logout();
            },
            icon: const Icon(Icons.logout, size: 20.0),
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.buildViews,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<QueryDocumentSnapshot>? documents = snapshot.data?.docs;

            if (documents == null || documents.isEmpty) {
              return const Text("No Data");
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final model = UserModel.fromMap(documents[index].data() as Map<String, dynamic>);
                if (!FirebaseService.isCurrentUser(model.email)) {
                  return UserCard(userModel: model);
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return FutureBuilder<UserModel?>(
  //       future: FirebaseService.currentUser,
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(child: CircularProgressIndicator());
  //         }
  //
  //         if (snapshot.hasData) {
  //           UserModel? currentUser = snapshot.data;
  //
  //           if (currentUser == null) {
  //             return const Center(child: Text("Problem in authorization. Please login again"));
  //           }
  //           return CallInvitationPage(
  //             username: currentUser.username,
  //             child: Scaffold(
  //               appBar: AppBar(
  //                 title: const Text("Sam Caller"),
  //                 actions: [
  //                   IconButton(
  //                     onPressed: () {
  //                       FirebaseService.logout();
  //                     },
  //                     icon: const Icon(Icons.logout, size: 20.0),
  //                   ),
  //                 ],
  //               ),
  //               body: Center(
  //                 child: StreamBuilder<QuerySnapshot>(
  //                   stream: FirebaseService.buildViews,
  //                   builder: (context, snapshot) {
  //                     if (!snapshot.hasData) {
  //                       return const Center(child: CircularProgressIndicator());
  //                     }
  //
  //                     final List<QueryDocumentSnapshot>? documents = snapshot.data?.docs;
  //
  //                     if (documents == null || documents.isEmpty) {
  //                       return const Text("No Data");
  //                     }
  //
  //                     return ListView.builder(
  //                       shrinkWrap: true,
  //                       itemCount: documents.length,
  //                       itemBuilder: (context, index) {
  //                         final model = UserModel.fromMap(documents[index].data() as Map<String, dynamic>);
  //                         if (!FirebaseService.isCurrentUser(model.email)) {
  //                           return UserCard(userModel: model);
  //                         }
  //                         return const SizedBox.shrink();
  //                       },
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ),
  //           );
  //         }
  //
  //         return const Center(child: Text("Please wait. We are setting things up."));
  //       }
  //   );
  // }
}
