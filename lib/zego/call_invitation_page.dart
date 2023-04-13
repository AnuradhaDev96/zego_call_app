// import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
//
// import '../common/statics.dart';
//
// class CallInvitationPage extends StatelessWidget {
//   const CallInvitationPage({Key? key, required this.child, required this.username}) : super(key: key);
//   final Widget child;
//   final String username;
//
//   @override
//   Widget build(BuildContext context) {
//     return ZegoUIKitPrebuiltCallWithInvitation(
//       appID: Statics.zegoAppId, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
//       appSign: Statics.zegoAppSign, // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
//       userID: username,
//       userName: username,
//       plugins: [
//         ZegoUIKitSignalingPlugin()
//       ],
//       child: child,
//     );
//   }
// }
