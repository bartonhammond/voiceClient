import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:voiceClient/app/sign_in/friend_button.dart';

import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/common_widgets/platform_alert_dialog.dart';
import 'package:voiceClient/common_widgets/staggered_grid_tile_message.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/mutation_service.dart';
import 'package:voiceClient/services/service_locator.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({
    Key key,
    this.onPush,
    this.onMessagesCount,
  }) : super(key: key);
  final ValueChanged<String> onPush;
  final void Function(int) onMessagesCount;

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
      updateFriendRequest(
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

      await updateFriendRequest(
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
                documentNode: gql(getUserMessages),
                variables: <String, dynamic>{
                  'email': graphQLAuth.getUser().email,
                  'status': 'new',
                },
                pollInterval: 10,
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
                if (result.data['User'][0]['messages']['from'].length != 0) {
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
                            return StaggeredGridTileMessage(
                              key: Key('${Keys.messageGridTile}_$index'),
                              onPush: widget.onPush,
                              message: messages[index],
                              approveFriendButton: FriendButton(
                                key: Key(
                                    '${Keys.approveFriendRequestButton}-$index'),
                                text: Strings.approveFriendButton.i18n,
                                onPressed: () =>
                                    _approveFriendRequest(messages[index]),
                              ),
                              rejectFriendButton: FriendButton(
                                  key: Key(
                                      '${Keys.rejectFriendRequestButton}-$index'),
                                  text: Strings.rejectFriendButton.i18n,
                                  onPressed: () =>
                                      _rejectFriendRequest(messages[index])),
                            );
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
