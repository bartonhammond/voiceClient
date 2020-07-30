import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:voiceClient/app/sign_in/friend_button.dart';

import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/common_widgets/platform_alert_dialog.dart';
import 'package:voiceClient/common_widgets/staggered_grid_tile_message.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/mutation_service.dart';
import 'package:voiceClient/services/service_locator.dart';

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
  final String title = 'My Family Voice';
  final nMessages = 20;
  final ScrollController _scrollController = ScrollController();
  int offset = 0;
  bool shouldBeMore = true;
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
  VoidCallback _refetchQuery;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _rejectFriendRequest(Map<String, dynamic> message) async {
    print("_rejectFriendRequest ${message['User']['id']}");
    final bool rejectFriendRequest = await PlatformAlertDialog(
      title: 'Reject Friendship Request?',
      content: 'Are you sure?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Yes',
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
    } else {
      print('do not add friend');
    }
  }

  Future<void> _approveFriendRequest(Map<String, dynamic> message) async {
    print("_approveFriendRequest ${message['User']['id']}");
    final bool approveFriendRequest = await PlatformAlertDialog(
      title: 'Approve Friendship Request?',
      content: 'Are you sure?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Yes',
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
        backgroundColor: NeumorphicTheme.currentTheme(context).variantColor,
        title: Text(
          title,
          style: TextStyle(color: Colors.black),
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
                  'status': 'new'
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

                final List<dynamic> messages =
                    result.data['User'][0]['messages']['from'];

                if (result.data['User'][0]['messages']['from'].length <
                    nMessages) {
                  shouldBeMore = false;
                }
                offset += nMessages;

                final FetchMoreOptions opts = FetchMoreOptions(
                  variables: <String, dynamic>{'offset': offset},
                  updateQuery: (dynamic previousResultData,
                      dynamic fetchMoreResultData) {
                    // this is where you combine your previous data and response
                    // in this case, we want to display previous repos plus next repos
                    // so, we combine data in both into a single list of repos
                    final List<dynamic> repos = <dynamic>[
                      ...previousResultData['User'][0]['messages']['from'],
                      ...fetchMoreResultData['User'][0]['messages']['from'],
                    ];

                    fetchMoreResultData['User'][0]['messages']['from'] = repos;

                    return fetchMoreResultData;
                  },
                );

                _scrollController
                  ..addListener(() {
                    if (_scrollController.position.pixels ==
                        _scrollController.position.maxScrollExtent) {
                      if (!result.loading && shouldBeMore) {
                        fetchMore(opts);
                      }
                    }
                  });

                return Expanded(
                  child: messages == null || messages.isEmpty
                      ? Text('No results')
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          primary: false,
                          itemBuilder: (context, index) =>
                              StaggeredGridTileMessage(
                            key: Key('${Keys.messageGridTile}_$index'),
                            onPush: widget.onPush,
                            message: messages[index],
                            approveFriendButton: FriendButton(
                              key: Key(
                                  '${Keys.approveFriendRequestButton}-$index'),
                              text: 'Approve',
                              onPressed: () =>
                                  _approveFriendRequest(messages[index]),
                            ),
                            rejectFriendButton: FriendButton(
                                key: Key(
                                    '${Keys.rejectFriendRequestButton}-$index'),
                                text: 'Reject',
                                onPressed: () =>
                                    _rejectFriendRequest(messages[index])),
                          ),
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
