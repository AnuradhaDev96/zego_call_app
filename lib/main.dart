import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:push_notifications_app/firebase_options.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'change_notifiers/call_state_change_notifier.dart';
import 'common/dependency_locator.dart';
import 'common/statics.dart';
import 'message_handler.dart';
import 'services/firebase_service.dart';
import 'zego/dashboard_page.dart';
import 'zego/login_page.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: "basic_channel",
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

  injectDependencies();

  FirebaseMessaging.onBackgroundMessage(MessageHandler.firebaseMessagingBackgroundHandler);

  Stripe.publishableKey = Statics.stripePublishableKey;

  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(MessageHandler.channel);

  // await FirebaseMessaging.instance.subscribeToTopic('TopicToListen');

  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );

  // final navigatorKey = GlobalKey<NavigatorState>();
  // ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  // FirebaseService.initializeZegoServiceIfUserLoggedIn();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  // static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(MyApp.navigatorKey);
    FirebaseService.initializeZegoServiceIfUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CallStateChangeNotifier(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: MyApp.navigatorKey,
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
      ),
    );
  }
}
