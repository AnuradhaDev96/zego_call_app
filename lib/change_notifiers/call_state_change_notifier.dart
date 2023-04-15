import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallStateChangeNotifier extends ChangeNotifier {
  bool _isIncomingCall = false;

  bool get isIncomingCall => _isIncomingCall;

  void toggleIncomingCallStatus(bool value, [ZegoCallUser? callerName]) {
    _isIncomingCall = value;
    _caller = callerName;
    notifyListeners();
  }

  ZegoCallUser? _caller;

  ZegoCallUser? get caller => _caller;

}