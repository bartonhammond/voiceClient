import 'package:MyFamilyVoice/services/auth_service_adapter.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';

class AppConfig extends InheritedWidget {
  const AppConfig({
    @required this.flavorName,
    @required this.apiBaseUrl,
    @required this.getHttpLink,
    @required this.isSecured,
    @required this.isWeb,
    this.authServiceType = AuthServiceType.firebase,
    this.mockEmail,
    @required Widget child,
  }) : super(child: child);

  final String flavorName;
  final String apiBaseUrl;
  final HttpLink Function(String) getHttpLink;
  final bool isSecured;
  final bool isWeb;
  final AuthServiceType authServiceType;
  final String mockEmail;

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
