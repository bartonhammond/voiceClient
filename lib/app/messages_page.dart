import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:voiceClient/app/sign_in/message_button.dart';

import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/common_widgets/platform_alert_dialog.dart';
import 'package:voiceClient/common_widgets/staggered_grid_tile_message.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/mutation_service.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';
import 'package:voiceClient/services/service_locator.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({
    Key key,
    this.onPush,
    this.params,
  }) : super(key: key);
  final ValueChanged<Map<String, dynamic>> onPush;
  final Map<String, dynamic> params;

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final String title = Strings.MFV.i18n;
  final nMessages = 20;
  final ScrollController _scrollController = ScrollController();
  bool shouldBeMore = true;
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
  VoidCallback _refetchQuery;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _rejectFriendRequest(Map<String, dynamic> message) async {
    final bool rejectFriendRequest = await PlatformAlertDialog(
      title: Strings.rejectFriendshipRequest.i18n,
      content: Strings.areYouSure.i18n,
      cancelActionText: Strings.cancel.i18n,
      defaultActionText: Strings.yes.i18n,
    ).show(context);
    if (rejectFriendRequest == true) {
      final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
      final GraphQLClient graphQLClient =
          graphQLAuth.getGraphQLClient(GraphQLClientType.ApolloServer);
      updateMessage(
        graphQLClient,
        message['User']['id'],
        graphQLAuth.getCurrentUserId(),
        message['id'],
        message['created']['formatted'],
        'reject', //status
        message['text'],
        message['type'],
      );
      _refetchQuery();
    }
  }

  Future<void> _approveFriendRequest(Map<String, dynamic> message) async {
    final bool approveFriendRequest = await PlatformAlertDialog(
      title: Strings.approveFriendshipRequest.i18n,
      content: Strings.areYouSure.i18n,
      cancelActionText: Strings.cancel.i18n,
      defaultActionText: Strings.yes.i18n,
    ).show(context);
    if (approveFriendRequest) {
      final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

      await addUserFriend(
        graphQLClient,
        message['User']['id'],
        graphQLAuth.getCurrentUserId(),
      );

      await addUserFriend(
        graphQLClient,
        graphQLAuth.getCurrentUserId(),
        message['User']['id'],
      );

      await updateMessage(
        graphQLClient,
        message['User']['id'],
        graphQLAuth.getCurrentUserId(),
        message['id'],
        message['created']['formatted'],
        'approve', //status
        message['text'],
        message['type'],
      );

      _refetchQuery();
    }

    return;
  }

  Future<void> callBack(Map<String, dynamic> message) async {
    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;
    await updateMessage(
      graphQLClient,
      message['User']['id'],
      graphQLAuth.getCurrentUserId(),
      message['id'],
      message['created']['formatted'],
      'done', //status
      message['text'],
      message['type'],
    );

    setState(() {});
  }

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff00bcd4),
        title: Text(
          title,
        ),
      ),
      drawer: getDrawer(context),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Query(
              options: QueryOptions(
                documentNode: gql(getUserMessagesQL),
                variables: <String, dynamic>{
                  'email': graphQLAuth.getUser().email,
                  'status': 'new',
                },
              ),
              builder: (
                QueryResult result, {
                VoidCallback refetch,
                FetchMore fetchMore,
              }) {
                _refetchQuery = refetch;
                if (result.loading && result.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (result.hasException) {
                  return Text('\nErrors: \n  ' + result.exception.toString());
                }
                List<dynamic> messages = <dynamic>[];
                if (result.data['User'].length > 0 &&
                    result.data['User'][0]['messages']['from'].length > 0) {
                  messages = List<dynamic>.from(
                      result.data['User'][0]['messages']['from']);
                }
                if (messages.isEmpty || messages.length % nMessages != 0) {
                  shouldBeMore = false;
                } else {
                  shouldBeMore = true;
                }

                return Expanded(
                  child: messages == null || messages.isEmpty
                      ? Center(
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Text(Strings.noResults.i18n),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          primary: false,
                          itemBuilder: (context, index) {
                            switch (messages[index]['type']) {
                              case 'friend-request':
                                return StaggeredGridTileMessage(
                                  title: Strings.friendRequest.i18n,
                                  key: Key('${Keys.messageGridTile}_$index'),
                                  message: messages[index],
                                  approveButton: MessageButton(
                                    key: Key(
                                        '${Keys.approveFriendRequestButton}-$index'),
                                    text: Strings.approveFriendButton.i18n,
                                    fontSize: 16,
                                    onPressed: () =>
                                        _approveFriendRequest(messages[index]),
                                    icon: Icon(
                                      MdiIcons.accountPlus,
                                      color: Colors.white,
                                    ),
                                  ),
                                  rejectButton: MessageButton(
                                    key: Key(
                                        '${Keys.rejectFriendRequestButton}-$index'),
                                    text: Strings.rejectFriendButton.i18n,
                                    fontSize: 16,
                                    onPressed: () =>
                                        _rejectFriendRequest(messages[index]),
                                    icon: Icon(
                                      MdiIcons.accountRemove,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                                break;
                              case 'comment':
                                return StaggeredGridTileMessage(
                                  title: Strings.commentRequest.i18n,
                                  key: Key('${Keys.messageGridTile}_$index'),
                                  message: messages[index],
                                  approveButton: MessageButton(
                                    key:
                                        Key('${Keys.viewCommentButton}-$index'),
                                    text: Strings.viewCommentButton.i18n,
                                    fontSize: 16,
                                    onPressed: () {
                                      widget.onPush(
                                        <String, dynamic>{
                                          'id': messages[index]['key1'],
                                          'onFinish': () {
                                            callBack(messages[index]);
                                          },
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      MdiIcons.accountPlus,
                                      color: Colors.white,
                                    ),
                                  ),
                                  rejectButton: MessageButton(
                                    key: Key(
                                        '${Keys.clearCommentButton}-$index'),
                                    text: Strings.clearCommentButton.i18n,
                                    fontSize: 16,
                                    onPressed: () => callBack(messages[index]),
                                    icon: Icon(
                                      MdiIcons.accountRemove,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                                break;
                              default:
                                return Container();
                            }
                          },
                        ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _build(context);
  }
}
