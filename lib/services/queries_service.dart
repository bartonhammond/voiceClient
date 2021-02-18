import 'package:MyFamilyVoice/ql/user/user_search.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Future<Map> getUserByEmail(
  GraphQLClient graphQLClient,
  String currentUserEmail,
) async {
  final UserQl userQL = UserQl();

  final UserSearch userSearch = UserSearch.init(
    graphQLClient,
    userQL,
    currentUserEmail,
  );
  userSearch.setQueryName('getUserByEmail');
  userSearch.setVariables(<String, dynamic>{
    'currentUserEmail': 'String!',
  });

  return await userSearch.getItem(<String, dynamic>{
    'currentUserEmail': 'bartonhammond@gmail.com',
  });
}
