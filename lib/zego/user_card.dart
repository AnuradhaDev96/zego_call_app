import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../models/user_model.dart';

class UserCard extends StatefulWidget {
  const UserCard({Key? key, required this.userModel}) : super(key: key);
  final UserModel userModel;

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 150.0,
      margin: const EdgeInsets.only(bottom: 12.0, left: 20.0, right: 20.0),
      padding: const EdgeInsets.only(bottom: 15.0, left: 8.0,),
      decoration: BoxDecoration(
        color: const Color(0xFFCBF1BF),
        borderRadius: BorderRadius.circular(12.5),
        boxShadow: [
          BoxShadow(
            offset: const Offset(10, 10),
            blurRadius: 10.0,
            spreadRadius: 0,
            color: Colors.grey.withOpacity(0.25),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            radius: 20.0,
            child: Center(
              child: Text(
                widget.userModel.name.substring(0, 1).toUpperCase(),
              ),
            ),
          ),
          const SizedBox(width: 15.0),
          Text(
            widget.userModel.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          // const Spacer(),
          actionButton(isVideoCall: false),
          // actionButton(),
        ],
      ),
    );
  }

  ZegoSendCallInvitationButton actionButton({bool isVideoCall = true}) => ZegoSendCallInvitationButton(
        isVideoCall: isVideoCall,
        // resourceID: "zegouikit_call",
        invitees: [
          ZegoUIKitUser(
            id: widget.userModel.username,
            name: widget.userModel.name,
          )
        ],
        // buttonSize: const Size(30.0, 30.0),
      );
}