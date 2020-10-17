import 'dart:io';
import 'package:graphql/client.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';

Future<String> addUser(
  GraphQLClient graphQLClientFileServer,
  GraphQLClient graphQLClient,
  Map<String, dynamic> user,
) async {
  final uuid = Uuid();
  final DateTime now = DateTime.now();

  final String id = uuid.v1();
  String jpegPathUrl;
  if (!user.containsKey('image')) {
    final MultipartFile multipartFile = getMultipartFile(
      File('./seed/profile/${user['profile']}.jpeg'),
      '$id.jpg',
      'image',
      'jpeg',
    );

    jpegPathUrl = await performMutation(
      graphQLClientFileServer,
      multipartFile,
      'jpeg',
    );
  }
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(createUser),
    variables: <String, dynamic>{
      'id': id,
      'email': user['email'],
      'name': user['name'],
      'home': user['home'],
      'image': user.containsKey('image') ? user['image'] : jpegPathUrl,
      'created': now.toIso8601String(),
    },
  );
  final QueryResult result = await graphQLClient.mutate(_mutationOptions);
  if (result.hasException) {
    throw result.exception;
  }
  return id;
}
