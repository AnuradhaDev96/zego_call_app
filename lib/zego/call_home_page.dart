import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../common/statics.dart';

class CallHomePage extends StatelessWidget {
  CallHomePage({Key? key, required this.callID}) : super(key: key);
  final String callID;

  String userId = Random().nextInt(1000).toString();
  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: Statics.zegoAppId, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
      appSign: Statics.zegoAppSign, // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
      userID: userId,
      userName: 'user_$userId',
      callID: callID,
      // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        ..onOnlySelfInRoom = (BuildContext context) => Navigator.of(context).pop(),
    );
  }
}