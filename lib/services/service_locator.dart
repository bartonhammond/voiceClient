import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';

GetIt locator = GetIt.instance;

void setupServiceLocator(BuildContext context) {
  if (locator.isRegistered<GraphQLAuth>()) {
    return;
  }
  locator.registerLazySingleton<GraphQLAuth>(() => GraphQLAuth(context));
}

void clearService() {
  locator.reset();
}
