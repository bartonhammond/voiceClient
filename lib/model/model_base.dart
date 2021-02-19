import 'package:uuid/uuid.dart';

abstract class ModelBase {
  ModelBase(this.alias);
  int alias;
  static int count = 0;
  String getParameterNamesAndTypes();
  Map<String, dynamic> getVariables();
  String getGqlWitAliasPrefix();
}

class GQLBuilder {
  GQLBuilder(this.mutationName);
  String mutationName;
  List<ModelBase> models = [];
  void add(ModelBase model) {
    models.add(model);
  }

  String getGQL() {
    String gql = 'mutation $mutationName(';
    bool first = true;
    for (var model in models) {
      if (!first) {
        gql += ', ';
      }
      gql += model.getParameterNamesAndTypes();
      first = false;
    }
    gql += ') {';
    for (var model in models) {
      gql += model.getGqlWitAliasPrefix();
    }
    gql += '}';
    return gql;
  }

  Map<String, dynamic> getVariables() {
    final Map map = <String, dynamic>{};
    for (var model in models) {
      map.addAll(model.getVariables());
    }
    return map;
  }
}

class Tag extends ModelBase {
  Tag({
    this.story,
    this.tag,
  }) : super(ModelBase.count++);
  Map<String, dynamic> story;
  Map<String, dynamic> tag;

  @override
  String getGqlWitAliasPrefix() {
    return '''
    tag$alias: createTag(
      tagId: \$tagId$alias
      created: \$created$alias
      storyId: \$storyId$alias
      userId: \$userId$alias
    ) 
    ''';
  }

  @override
  String getParameterNamesAndTypes() {
    return '\$tagId$alias: String!, \$created$alias: String!, \$storyId$alias: String!, \$userId$alias: String!';
  }

  @override
  Map<String, dynamic> getVariables() {
    final DateTime now = DateTime.now();
    final _uuid = Uuid();
    return <String, dynamic>{
      'tagId$alias': _uuid.v1(),
      'created$alias': now.toIso8601String(),
      'storyId$alias': story['id'],
      'userId$alias': tag['user']['id']
    };
  }
}

class Message extends ModelBase {
  Message({
    this.currentUser,
    this.tag,
    this.status,
    this.type,
    this.key,
  }) : super(ModelBase.count++);
  Map<String, dynamic> currentUser;
  String status;
  String type;
  String key;
  Map<String, dynamic> tag;

  @override
  String getGqlWitAliasPrefix() {
    return '''
    message$alias: createMessage(
      messageId: \$messageId$alias
      created: \$created$alias
      status: \$status$alias
      type: \$type$alias
      key: \$key$alias
      fromUserId: \$fromUserId$alias
      toUserId: \$toUserId$alias
    ) 
    ''';
  }

  @override
  String getParameterNamesAndTypes() {
    return '''\$messageId$alias: String!, 
    \$created$alias: String!, 
    \$status$alias: String!, 
    \$type$alias: String!,
    \$key$alias: String!
    \$fromUserId$alias: String!
    \$toUserId$alias: String!
    ''';
  }

  @override
  Map<String, dynamic> getVariables() {
    final DateTime now = DateTime.now();
    final _uuid = Uuid();
    return <String, dynamic>{
      'messageId$alias': _uuid.v1(),
      'created$alias': now.toIso8601String(),
      'status$alias': status,
      'type$alias': type,
      'key$alias': key,
      'fromUserId$alias': currentUser['id'],
      'toUserId$alias': tag['user']['id'],
    };
  }
}
