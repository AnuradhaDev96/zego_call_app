import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../change_notifiers/call_state_change_notifier.dart';
import '../common/statics.dart';
import '../main.dart';
import '../models/call_history_record.dart';
import '../models/enums/call_type.dart';
import '../models/user_model.dart';

class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _store = FirebaseFirestore.instance;

  static UserModel? _currentUser;

  static Future<UserModel?> get currentUser async {
    if (_currentUser == null) {
      final document = await _store.collection("users").doc(_auth.currentUser!.uid).get();
      final data = document.data();
      if (data != null) {
        _currentUser = UserModel.fromMap(data);
      }
    }

    return _currentUser;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> get buildViews => _store.collection("users").snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> get buildCallHistoryOfCurrentUser =>
      _store.collection("users").doc(_auth.currentUser!.uid).collection("call_history").orderBy("time").snapshots();

  static Future<bool> signUp({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final credentials = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      final UserModel user = UserModel(email: email, name: name, username: username);

      if (credentials.user != null) {
        final documentReference = _store.collection("users").doc(credentials.user!.uid);
        final document = await documentReference.get();
        if (document.exists) {
          return false;
        }

        await documentReference.set(user.toMap());
        _currentUser = user;
        return true;
      }

      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final credentials = await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (credentials.user != null) {
        final document = await _store.collection("users").doc(credentials.user!.uid).get();
        final data = document.data();
        if (data != null) {
          _currentUser = UserModel.fromMap(data);

          await updateFCMToken(document);
          await initializeDefaultZegoService(_currentUser!.username, _currentUser!.username);
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static void logout() async {
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
    _auth.signOut();
  }

  static bool isCurrentUser(String email) {
    return _auth.currentUser?.email == email;
  }

  static void initializeZegoServiceIfUserLoggedIn() async {
    if (_auth.currentUser?.email != null) {
      var user = await currentUser;
      await initializeDefaultZegoService(user!.username, user.username);
    }
  }

  static Future<void> initializeDefaultZegoService(String userId, String username) async {
    var callStatusNotifier = Provider.of<CallStateChangeNotifier>(MyApp.navigatorKey.currentContext!, listen: false);

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: Statics.zegoAppId /*input your AppID*/,
      appSign: Statics.zegoAppSign /*input your AppSign*/,
      userID: userId,
      userName: username,
      plugins: [ZegoUIKitSignalingPlugin()],
      events: ZegoUIKitPrebuiltCallInvitationEvents(
        onIncomingCallReceived:
            (String callID, ZegoCallUser caller, ZegoCallType callType, List<ZegoCallUser> callees) {
          Provider.of<CallStateChangeNotifier>(MyApp.navigatorKey.currentContext!, listen: false)
              .toggleIncomingCallStatus(true, caller);
        },
        onIncomingCallAcceptButtonPressed: () async {
          CallHistoryRecord record = CallHistoryRecord(
              callResult: CallType.received, time: DateTime.now(), callerUsername: callStatusNotifier.caller!.id);
          await saveCallHistoryRecord(record);

          callStatusNotifier.toggleIncomingCallStatus(false);
        },
        onIncomingCallDeclineButtonPressed: () async {
          CallHistoryRecord record = CallHistoryRecord(
              callResult: CallType.received, time: DateTime.now(), callerUsername: callStatusNotifier.caller!.id);
          await saveCallHistoryRecord(record);

          callStatusNotifier.toggleIncomingCallStatus(false);
        },
        onIncomingCallCanceled: (String callID, ZegoCallUser caller) async {
          CallHistoryRecord record =
              CallHistoryRecord(callResult: CallType.missed, time: DateTime.now(), callerUsername: caller.id);
          await saveCallHistoryRecord(record);

          Provider.of<CallStateChangeNotifier>(MyApp.navigatorKey.currentContext!, listen: false)
              .toggleIncomingCallStatus(false);
        },
        onIncomingCallTimeout: (String callID, ZegoCallUser caller) async {
          CallHistoryRecord record =
              CallHistoryRecord(callResult: CallType.missed, time: DateTime.now(), callerUsername: caller.id);
          await saveCallHistoryRecord(record);

          Provider.of<CallStateChangeNotifier>(MyApp.navigatorKey.currentContext!, listen: false)
              .toggleIncomingCallStatus(false);
        },
      ),
    );
  }

  static Future<void> updateFCMToken(DocumentSnapshot document) async {
    await FirebaseMessaging.instance.getToken().then((value) async {
      var user = await currentUser;
      user?.fcmToken = value;
      await document.reference.update(user!.toMap());
    });
  }

  static Future<void> saveCallHistoryRecord(CallHistoryRecord historyRecord) async {
    var id = await _store
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("call_history")
        .add(historyRecord.toMap());
  }


}
