import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:voiceClient/app/sign_in/custom_raised_button.dart';

import 'package:voiceClient/app/sign_in/message_button.dart';

import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/common_widgets/platform_alert_dialog.dart';
import 'package:voiceClient/common_widgets/staggered_grid_tile_message.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/services/eventBus.dart';
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
  final nMessages = 20;
  int lastResultSetSize = 0;

  final ScrollController _scrollController = ScrollController();
  bool _shouldBeMore = true;
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

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

      await updateUserMessageStatusById(
        graphQLClient,
        graphQLAuth.getUser().email,
        message['id'],
        'reject', //status
      );
      setState(() {});
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

      await updateUserMessageStatusById(
        graphQLClient,
        graphQLAuth.getUser().email,
        message['id'],
        'approve', //status
      );
    }
    setState(() {});
    return;
  }

  ///
  ///Update the message to status of 'done' so that query
  ///won't pick it up
  ///
  Future<void> callBack(Map<String, dynamic> message) async {
    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;
    await updateUserMessageStatusById(
      graphQLClient,
      graphQLAuth.getUser().email,
      message['id'],
      'cleared', //status
    );

    setState(() {});
  }

  Widget getDetailWidget(List<dynamic> messages, int index) {
    switch (messages[index]['type']) {
      case 'friend-request':
        return StaggeredGridTileMessage(
          title: Strings.friendRequest.i18n,
          key: Key('${Keys.messageGridTile}_$index'),
          message: messages[index],
          approveButton: MessageButton(
            key: Key('${Keys.approveFriendRequestButton}-$index'),
            text: Strings.approveFriendButton.i18n,
            fontSize: 16,
            onPressed: () => _approveFriendRequest(messages[index]),
            icon: Icon(
              MdiIcons.accountPlus,
              color: Colors.white,
            ),
          ),
          rejectButton: MessageButton(
            key: Key('${Keys.rejectFriendRequestButton}-$index'),
            text: Strings.rejectFriendButton.i18n,
            fontSize: 16,
            onPressed: () => _rejectFriendRequest(messages[index]),
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
            key: Key('${Keys.viewCommentButton}-$index'),
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
            key: Key('${Keys.clearCommentButton}-$index'),
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
  }

  String getCursor(List<dynamic> _list) {
    String datetime;
    if (_list == null || _list.isEmpty) {
      datetime = DateTime.now().toIso8601String();
    } else {
      datetime = _list[_list.length - 1]['created']['formatted'];
    }
    return datetime;
  }

  Widget getLoadMoreButton(
    FetchMore fetchMore,
    List<dynamic> messages,
  ) {
    return CustomRaisedButton(
        text: Strings.loadMore.i18n,
        icon: Icon(
          Icons.arrow_downward,
          color: Colors.white,
        ),
        onPressed: () {
          final FetchMoreOptions opts = FetchMoreOptions(
            variables: <String, dynamic>{
              'cursor': getCursor(messages),
            },
            updateQuery:
                (dynamic previousResultData, dynamic fetchMoreResultData) {
              _shouldBeMore = fetchMoreResultData['userMessages'].length > 0;

              final List<dynamic> data = <dynamic>[
                ...previousResultData['userMessages'],
                ...fetchMoreResultData['userMessages'],
              ];

              fetchMoreResultData['userMessages'] = data;

              return fetchMoreResultData;
            },
          );
          fetchMore(opts);
        });
  }

  Widget handleEmptyMessages() {
    //The listener is in FABBottomAppBar
    eventBus.fire(MessagesEvent(true));
    return Center(
      child: Container(
        child: Column(
          children: <Widget>[
            Text(Strings.noResults.i18n),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('messages_page build');
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    int _staggeredViewSize = 2;
    int _crossAxisCount = 4;
    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        _staggeredViewSize = 1;
        _crossAxisCount = 3;
        break;
      case DeviceScreenType.watch:
        _crossAxisCount = 1;
        break;
      default:
        _staggeredViewSize = 1;
        _crossAxisCount = 1;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff00bcd4),
        title: Text(Strings.MFV.i18n),
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
                  'limit': '20',
                  'cursor': DateTime.now().toIso8601String(),
                },
              ),
              builder: (
                QueryResult result, {
                VoidCallback refetch,
                FetchMore fetchMore,
              }) {
                if (result.loading && result.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (result.hasException) {
                  return Text('\nErrors: \n  ' + result.exception.toString());
                }

                final List<dynamic> messages = <dynamic>[];

                ///barton
                ///convert
                if (result.data['userMessages'].length > 0) {
                  for (final tmp in result.data['userMessages']) {
                    final Map<String, dynamic> message = <String, dynamic>{};
                    message['id'] = tmp['messageId'];
                    message['type'] = tmp['messageType'];
                    message['created'] = tmp['messageCreated'];
                    message['text'] = tmp['messageText'];
                    message['status'] = tmp['messageStatus'];

                    message['key1'] = tmp['messageKey1'];
                    message['User'] = <String, dynamic>{};
                    message['User']['id'] = tmp['userId'];
                    message['User']['email'] = tmp['userEmail'];
                    message['User']['name'] = tmp['userName'];
                    message['User']['home'] = tmp['userHome'];
                    message['User']['image'] = tmp['userImage'];
                    message['User']['birth'] = tmp['userBirth'];
                    messages.add(message);
                  }
                  eventBus.fire(MessagesEvent(false));
                }

                if (messages.isEmpty || messages.length < nMessages) {
                  _shouldBeMore = false;
                }

                return Expanded(
                  child: messages == null || messages.isEmpty
                      ? handleEmptyMessages()
                      : StaggeredGridView.countBuilder(
                          controller: _scrollController,
                          itemCount: messages.length + 1,
                          primary: false,
                          crossAxisCount: _crossAxisCount,
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                          itemBuilder: (context, index) {
                            return index < messages.length
                                ? getDetailWidget(messages, index)
                                : _shouldBeMore
                                    ? getLoadMoreButton(fetchMore, messages)
                                    : Container();
                          },
                          staggeredTileBuilder: (index) =>
                              StaggeredTile.fit(_staggeredViewSize),
                        ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
