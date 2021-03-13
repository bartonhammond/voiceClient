import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Future<void> updateFirebaseUserToken(
  GraphQLClient graphQLClient,
  Map userMap,
  String newToken,
) async {
  final List<String> tokens =
      userMap['token'] == null ? <String>[] : userMap['token'].split(',');
  if (tokens.isNotEmpty) {
    for (var token in tokens) {
      if (newToken == token) {
        return;
      }
    }
  }

  tokens.add(newToken);

  await updateUserToken(
    graphQLClient,
    currentUserEmail: userMap['email'],
    tokens: tokens.join(','),
  );
}
