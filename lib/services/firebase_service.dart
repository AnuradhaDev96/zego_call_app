import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../change_notifiers/call_state_change_notifier.dart';
import '../common/statics.dart';
import '../main.dart';
import '../models/call_history_record.dart';
import '../models/enums/call_type.dart';
import '../models/enums/online_status.dart';
import '../models/enums/subscription.dart';
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

  static Future<bool> get isPremiumAccount async =>
      await currentUser.then((userModel) => userModel?.currentPackage == Subscription.premium);

  static Stream<QuerySnapshot<Map<String, dynamic>>> get buildViews => _store.collection("users").snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> get buildCallHistoryOfCurrentUser =>
      _store.collection("users").doc(_auth.currentUser!.uid).collection("call_history").orderBy("time").snapshots();

  static Stream<DocumentSnapshot<Map<String, dynamic>>> get currentUserSnapshot =>
      _store.collection("users").doc(_auth.currentUser!.uid).snapshots();

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

        await createUserRecordWithFCMToken(documentReference, user);
        await initializeDefaultZegoService(_currentUser!.username, _currentUser!.username);
        await setOnlineStatus(OnlineStatus.online);
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
          await setOnlineStatus(OnlineStatus.online);
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
    await setOnlineStatus(OnlineStatus.offline).then((value) {
      _currentUser = null;
      _auth.signOut();
    });
  }

  static bool isCurrentUser(String email) {
    return _auth.currentUser?.email == email;
  }

  static void initializeZegoServiceIfUserLoggedIn() async {
    if (_auth.currentUser?.email != null) {
      var user = await currentUser;
      await initializeDefaultZegoService(user!.username, user.username);
      setOnlineStatus(OnlineStatus.online);
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

  static Future<void> createUserRecordWithFCMToken(DocumentReference documentReference, UserModel userModel) async {
    await FirebaseMessaging.instance.getToken().then((value) async {
      userModel.fcmToken = value;
      await documentReference.set(userModel.toMap());
      _currentUser = userModel;
    });
  }

  static Future<void> saveCallHistoryRecord(CallHistoryRecord historyRecord) async {
    var id = await _store
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("call_history")
        .add(historyRecord.toMap());
  }

  static Future<bool> loginWithGoogle() async {
    //google_sign_in package
    GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
    if (googleSignInAccount != null) {
      GoogleSignInAuthentication? googleAuth = await googleSignInAccount.authentication;

      //Firebase auth package
      AuthCredential credential =
          GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      UserCredential firebaseCredentials = await _auth.signInWithCredential(credential);
      debugPrint("Google sign user: ${firebaseCredentials.user?.displayName}");

      if (firebaseCredentials.user != null) {
        final documentReference = _store.collection("users").doc(firebaseCredentials.user!.uid);
        var document = await documentReference.get();

        // check user is registered before
        if (document.exists && document.data() != null) {
          // user has registered and trying to login with initialization
          _currentUser = UserModel.fromMap(document.data()!);

          await updateFCMToken(document);
          await initializeDefaultZegoService(_currentUser!.username, _currentUser!.username);
          await setOnlineStatus(OnlineStatus.online);
          return true;
        } else {
          // new user record should be created and initialize data
          final UserModel user = UserModel(
            email: firebaseCredentials.user!.email!,
            name: firebaseCredentials.user!.displayName!,
            username: firebaseCredentials.user!.email!,
          );

          await createUserRecordWithFCMToken(documentReference, user);
          await initializeDefaultZegoService(_currentUser!.username, _currentUser!.username);
          return true;
        }
      }
    }
    return false;
  }

  static Future<void> updateToPremiumPackageCurrentUser() async {
    final document = await _store.collection("users").doc(_auth.currentUser!.uid).get();

    var user = await currentUser;
    user?.currentPackage = Subscription.premium;
    await document.reference.update(user!.toMap());
    _currentUser?.currentPackage = user.currentPackage;

    _userSubscriptionController.sink.add(await isPremiumAccount);
  }

  static final StreamController<bool> _userSubscriptionController = StreamController<bool>.broadcast();

  static Stream<bool> get currentSubscriptionStream => _userSubscriptionController.stream;

  static Future<void> setOnlineStatus(OnlineStatus onlineStatus) async {
    print("Online status based on app: ${onlineStatus.toDisplayString()}");
    final document = await _store.collection("users").doc(_auth.currentUser!.uid).get();

    if (document.exists) {
      var currentUserModel = await currentUser;
      if (currentUserModel != null) {
        currentUserModel.onlineStatus = onlineStatus;
        await document.reference.update(currentUserModel.toMap());
      }
    }
  }
}
