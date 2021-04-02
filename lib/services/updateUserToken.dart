import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:MyFamilyVoice/services/utilities.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:MyFamilyVoice/constants/globals.dart' as globals;

Future<void> updateFirebaseUserToken(
  GraphQLClient graphQLClient,
  Map userMap,
  String newToken,
) async {
  final Map<String, String> tokenMap = fromStringToTokenMap(userMap['tokens']);

  //already have it?
  if (tokenMap.containsKey(globals.deviceId) &&
      tokenMap[globals.deviceId] == newToken) {
    return;
  }

  tokenMap[globals.deviceId] = newToken;

  await updateUserToken(
    graphQLClient,
    currentUserEmail: userMap['email'],
    tokens: fromTokenMaptoString(tokenMap),
  );
}
