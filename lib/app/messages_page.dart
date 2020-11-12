import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';

import 'package:MyFamilyVoice/app/sign_in/message_button.dart';

import 'package:MyFamilyVoice/common_widgets/drawer_widget.dart';
import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/common_widgets/staggered_grid_tile_message.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:MyFamilyVoice/constants/keys.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/eventBus.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;

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

  MessageType _messageType;

  // VoidCallback _refetchQuery;

  final ScrollController _scrollController = ScrollController();

  Map<int, bool> moreSearchResults = {
    0: true,
    1: true,
    2: true,
    3: true,
  };

  Map<int, String> searchResultsName = {
    0: 'userMessages',
    1: 'userMessagesByType',
    2: 'userMessagesByType',
    3: 'userMessagesByType',
  };
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

  @override
  void initState() {
    _messageType = MessageType.ALL;
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
      try {
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
      } catch (e) {
        logger.createMessage(
            userEmail: graphQLAuth.getUser().email,
            source: 'messages_page',
            shortMessage: e.exception.toString(),
            stackTrace: StackTrace.current.toString());
        rethrow;
      }
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
      try {
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
      } catch (e) {
        logger.createMessage(
            userEmail: graphQLAuth.getUser().email,
            source: 'messages_page',
            shortMessage: e.exception.toString(),
            stackTrace: StackTrace.current.toString());
        rethrow;
      }
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
    try {
      await updateUserMessageStatusById(
        graphQLClient,
        graphQLAuth.getUser().email,
        message['id'],
        'cleared', //status
      );

      setState(() {});
    } catch (e) {
      logger.createMessage(
          userEmail: graphQLAuth.getUser().email,
          source: 'messages_page',
          shortMessage: e.exception.toString(),
          stackTrace: StackTrace.current.toString());
      rethrow;
    }
  }

  Widget getDetailWidget(Map<String, dynamic> _message, int index) {
    final Map<String, dynamic> message = <String, dynamic>{};
    message['id'] = _message['messageId'];
    message['type'] = _message['messageType'];
    message['created'] = _message['messageCreated'];
    message['text'] = _message['messageText'];
    message['status'] = _message['messageStatus'];

    message['key1'] = _message['messageKey1'];
    message['User'] = <String, dynamic>{};
    message['User']['id'] = _message['userId'];
    message['User']['email'] = _message['userEmail'];
    message['User']['name'] = _message['userName'];
    message['User']['home'] = _message['userHome'];
    message['User']['image'] = _message['userImage'];

    switch (message['type']) {
      case 'friend-request':
        return StaggeredGridTileMessage(
          title: Strings.friendRequest.i18n,
          key: Key('${Keys.messageGridTile}_$index'),
          message: message,
          approveButton: MessageButton(
            key: Key('${Keys.approveFriendRequestButton}-$index'),
            text: Strings.approveFriendButton.i18n,
            fontSize: 16,
            onPressed: () => _approveFriendRequest(message),
            icon: Icon(
              MdiIcons.accountPlus,
              color: Colors.white,
            ),
          ),
          rejectButton: MessageButton(
            key: Key('${Keys.rejectFriendRequestButton}-$index'),
            text: Strings.rejectFriendButton.i18n,
            fontSize: 16,
            onPressed: () => _rejectFriendRequest(message),
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
          message: message,
          approveButton: MessageButton(
            key: Key('${Keys.viewCommentButton}-$index'),
            text: Strings.viewCommentButton.i18n,
            fontSize: 16,
            onPressed: () {
              widget.onPush(
                <String, dynamic>{
                  'id': message['key1'],
                  'onFinish': () {
                    callBack(_message);
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
            onPressed: () => callBack(message),
            icon: Icon(
              MdiIcons.accountRemove,
              color: Colors.white,
            ),
          ),
        );
        break;

      case 'message':
        return StaggeredGridTileMessage(
          title: Strings.messagesPageMessage.i18n,
          key: Key('${Keys.messageGridTile}_$index'),
          message: message,
          isAudio: true,
          approveButton: null,
          rejectButton: MessageButton(
            key: Key('deleteMessage-$index'),
            text: Strings.messagesPageDeleteMessage.i18n,
            fontSize: 16,
            onPressed: () => callBack(message),
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
      datetime = _list[_list.length - 1]['messageCreated']['formatted'];
    }
    return datetime;
  }

  void isThereMoreSearchResults(dynamic fetchMoreResultData) {
    moreSearchResults[_messageType.index] =
        fetchMoreResultData[searchResultsName[_messageType.index]].length > 0;
  }

  Widget getLoadMoreButton(
    FetchMore fetchMore,
    List<dynamic> messages,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
      child: CustomRaisedButton(
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
              final List<dynamic> data = <dynamic>[
                ...previousResultData[searchResultsName[_messageType.index]],
                ...fetchMoreResultData[searchResultsName[_messageType.index]],
              ];
              isThereMoreSearchResults(fetchMoreResultData);
              fetchMoreResultData[searchResultsName[_messageType.index]] = data;
              return fetchMoreResultData;
            },
          );
          fetchMore(opts);
        },
      ),
    );
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

  Widget getDropDownTypeMessageButtons() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<MessageType>(
        value: _messageType,
        items: [
          DropdownMenuItem(
            child: Text(Strings.messagesPageMessageAll.i18n),
            value: MessageType.ALL,
          ),
          DropdownMenuItem(
            child: Text(Strings.messagesPageMessage.i18n),
            value: MessageType.MESSAGE,
          ),
          DropdownMenuItem(
            child: Text(Strings.messagesPageMessageComments.i18n),
            value: MessageType.COMMENT,
          ),
          DropdownMenuItem(
            child: Text(Strings.messagesPageMessageFriendRequests.i18n),
            value: MessageType.FRIEND_REQUEST,
          ),
        ],
        onChanged: (value) {
          setState(() {
            _messageType = value;
          });
        },
      ),
    );
  }

  QueryOptions getQueryOptions() {
    String gqlString;

    final _variables = <String, dynamic>{
      'email': graphQLAuth.getUser().email,
      'status': 'new',
      'limit': '20',
      'cursor': DateTime.now().toIso8601String(),
    };
    switch (_messageType) {
      case MessageType.ALL:
        gqlString = getUserMessagesQL;
        break;
      case MessageType.COMMENT:
        gqlString = getUserMessagesByTypeQL;
        _variables['type'] = 'comment';
        break;
      case MessageType.MESSAGE:
        gqlString = getUserMessagesByTypeQL;
        _variables['type'] = 'message';
        break;
      case MessageType.FRIEND_REQUEST:
        gqlString = getUserMessagesByTypeQL;
        _variables['type'] = 'friend-request';
        break;
    }
    return QueryOptions(
      documentNode: gql(gqlString),
      variables: _variables,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                getDropDownTypeMessageButtons(),
              ],
            ),
            Divider(),
            Query(
              options: getQueryOptions(),
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
                  logger.createMessage(
                      userEmail: graphQLAuth.getUser().email,
                      source: 'messages_page',
                      shortMessage: result.exception.toString(),
                      stackTrace: StackTrace.current.toString());
                  return Text('\nErrors: \n  ' + result.exception.toString());
                }
                //_refetchQuery = refetch;
                final List<dynamic> messages = List<dynamic>.from(
                    result.data[searchResultsName[_messageType.index]]);

                if (messages.isEmpty || messages.length < nMessages) {
                  moreSearchResults[_messageType.index] = false;
                } else {
                  eventBus.fire(MessagesEvent(false));
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
                                ? getDetailWidget(messages[index], index)
                                : moreSearchResults[_messageType.index]
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
