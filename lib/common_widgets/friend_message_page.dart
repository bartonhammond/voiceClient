import 'dart:async';

import 'package:MyFamilyVoice/common_widgets/friend_widget.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/check_proxy.dart';
import 'package:MyFamilyVoice/services/eventBus.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

class FriendMessagePage extends StatefulWidget {
  const FriendMessagePage({
    this.user,
  });
  final Map<String, dynamic> user;
  @override
  FriendMessagePageState createState() => FriendMessagePageState();
}

class FriendMessagePageState extends State<FriendMessagePage> {
  StreamSubscription proxyStartedSubscription;
  StreamSubscription proxyEndedSubscription;
  @override
  void initState() {
    super.initState();
    proxyStartedSubscription = eventBus.on<ProxyStarted>().listen((event) {
      setState(() {});
    });
    proxyEndedSubscription = eventBus.on<ProxyEnded>().listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    proxyStartedSubscription.cancel();
    proxyEndedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    return Scaffold(
        appBar: AppBar(
          title: Text(Strings.messagesPageMessage.i18n),
          actions: checkProxy(
            graphQLAuth,
            context,
          ),
        ),
        body: Padding(
          child: ListView(
            children: <Widget>[
              FriendWidget(user: widget.user),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ));
  }
}
