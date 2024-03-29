import 'dart:async';
import 'package:MyFamilyVoice/app/messages_detail.dart';
import 'package:MyFamilyVoice/ql/message/message_search.dart';
import 'package:MyFamilyVoice/ql/message_ql.dart';
import 'package:MyFamilyVoice/ql/story/story_comments.dart';
import 'package:MyFamilyVoice/ql/story/story_original_user.dart';
import 'package:MyFamilyVoice/ql/story/story_reactions.dart';
import 'package:MyFamilyVoice/ql/story/story_search.dart';
import 'package:MyFamilyVoice/ql/story/story_tags.dart';
import 'package:MyFamilyVoice/ql/story/story_user.dart';
import 'package:MyFamilyVoice/ql/story_ql.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:MyFamilyVoice/common_widgets/message_button.dart';
import 'package:MyFamilyVoice/common_widgets/drawer_widget.dart';
import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/common_widgets/staggered_grid_tile_message.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
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
  GraphQLClient graphQLClient;
  //VoidCallback _refetchQuery;

  final ScrollController _scrollController = ScrollController();

  Map<int, bool> moreSearchResults = {
    0: true,
    1: true,
    2: true,
    3: true,
    4: true,
    5: true,
  };

  Map<int, String> searchResultsName = {
    0: 'userMessagesReceived',
    1: 'userMessagesByType',
    2: 'userMessagesByType',
    3: 'userMessagesByType',
    4: 'userMessagesByType',
    5: 'userMessagesByType',
  };
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

  MessageQl messageQl = MessageQl();
  bool familyCheckboxValue = false;

  @override
  void initState() {
    _messageType = MessageType.ALL;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
        final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

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

  Future<void> _approveFriendRequest(
      Map<String, dynamic> message, bool familyCheckboxValue) async {
    final bool approveFriendRequest = await PlatformAlertDialog(
      key: Key('approveFriendRequest'),
      title: Strings.approveFriendshipRequest.i18n,
      content: Strings.areYouSure.i18n,
      cancelActionText: Strings.cancel.i18n,
      defaultActionText: Strings.yes.i18n,
    ).show(context);
    if (approveFriendRequest) {
      try {
        await addUserFriends(graphQLClient,
            userId1: message['sender']['id'],
            userId2: message['book'] == null
                ? graphQLAuth.getUserMap()['id']
                : message['book']['id'],
            isFamily1To2: false,
            isFamily2To1: familyCheckboxValue);

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
            shortMessage: e.toString(),
            stackTrace: StackTrace.current.toString());
        rethrow;
      }
    }
    setState(() {});
    return;
  }

  void onFamilyCheckboxClicked(bool value) {
    familyCheckboxValue = value;
  }

  ///
  ///Update the message to status of 'cleared' so that query
  ///won't pick it up
  ///
  Future<void> callBack(Map<String, dynamic> message) async {
    if (message == null || message['id'] == null) {
      return;
    }
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
          shortMessage: e.toString(),
          stackTrace: StackTrace.current.toString());
      rethrow;
    }
  }

  Widget getDetailWidget(Map<String, dynamic> message, int index) {
    switch (message['type']) {
      case 'friend-request':
        return StaggeredGridTileMessage(
          title: Strings.friendRequest.i18n,
          key: Key('${Keys.messageGridTile}_$index'),
          message: message,
          onFamilyCheckboxClicked: onFamilyCheckboxClicked,
          approveButton: MessageButton(
            key: Key('friend-request-approve-${message["sender"]["email"]}'),
            text: Strings.approveFriendButton.i18n,
            fontSize: 16,
            onPressed: () =>
                _approveFriendRequest(message, familyCheckboxValue),
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
            onPressed: () async {
              await displayStoryUI(
                message['key'],
                true,
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

      case 'attention':
        return StaggeredGridTileMessage(
          title: Strings.storyPlayAttention.i18n,
          key: Key('${Keys.messageGridTile}_$index'),
          message: message,
          approveButton: MessageButton(
            key: Key('viewAttention-$index'),
            text: Strings.messagesPageViewStory,
            fontSize: 16,
            onPressed: () async {
              await displayStoryUI(message['key'], false);
            },
            icon: Icon(
              Icons.group_add,
              size: 20,
              color: Colors.white,
            ),
          ),
          rejectButton: MessageButton(
            key: Key('${Keys.clearCommentButton}_$index'),
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

      case 'book':
        return StaggeredGridTileMessage(
          title: Strings.messagesPageMessageStoryAssignedToBook,
          key: Key('${Keys.messageGridTile}_book_$index'),
          message: message,
          approveButton: MessageButton(
            key: Key('viewBook-$index'),
            text: Strings.messagesPageViewStory,
            fontSize: 16,
            onPressed: () {
              widget.onPush(
                <String, dynamic>{
                  'id': message['key'],
                  'onFinish': () {
                    callBack(message);
                  },
                },
              );
            },
            icon: Icon(
              Icons.group_add,
              size: 20,
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
      default:
        return Text('invalid message type ${message['type']}');
    }
  }

  Future<void> displayStoryUI(String key, bool openComments) async {
    final StoryOriginalUser storyOriginalUser = StoryOriginalUser();
    final StoryComments storyComments = StoryComments();
    final StoryReactions storyReactions = StoryReactions();
    final StoryTags storyTags = StoryTags();
    final StoryUser storyUser = StoryUser();

    final StoryQl storyQl = StoryQl(
      storyUser: storyUser,
      storyOriginalUser: storyOriginalUser,
      storyComments: storyComments,
      storyReactions: storyReactions,
      storyTags: storyTags,
    );

    final StorySearch storySearch = StorySearch.init(
      graphQLClient,
      storyQl,
      graphQLAuth.getUser().email,
    );
    storySearch.setQueryName('getStoryById');
    storySearch.setVariables(
      <String, dynamic>{
        'id': 'String!',
        'currentUserEmail': 'String!',
      },
    );

    final Map story = await storySearch.getItem(<String, dynamic>{
      'id': key,
      'currentUserEmail': graphQLAuth.getUser().email,
    });

    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => MessagesDetail(
          story: story,
          openComments: openComments,
        ),
        fullscreenDialog: false,
      ),
    );
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
            Text(
              Strings.noResults.i18n,
              key: Key('noMessages'),
            ),
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
            child: Text(
              Strings.messagesPageMessageAll.i18n,
              key: Key('messagesPageAll'),
            ),
            value: MessageType.ALL,
          ),
          DropdownMenuItem(
            child: Text(
              Strings.storyPlayAttention.i18n,
              key: Key('messagesPageAttention'),
            ),
            value: MessageType.ATTENTION,
          ),
          DropdownMenuItem(
            child: Text(
              Strings.messagesPageMessage.i18n,
              key: Key('messagesPageMessage'),
            ),
            value: MessageType.MESSAGE,
          ),
          DropdownMenuItem(
            child: Text(Strings.messagesPageMessageComments.i18n,
                key: Key('messagesPageComment')),
            value: MessageType.COMMENT,
          ),
          DropdownMenuItem(
            child: Text(Strings.messagesPageMessageFriendRequests.i18n,
                key: Key('messagesPageFriendRequest')),
            value: MessageType.FRIEND_REQUEST,
          ),
          DropdownMenuItem(
            child: Text(Strings.messagesPageMessageBook.i18n,
                key: Key('messagesPageBook')),
            value: MessageType.BOOK,
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
    final _values = <String, dynamic>{
      'currentUserEmail': graphQLAuth.getUser().email,
      'status': 'new',
      'limit': '20',
      'cursor': DateTime.now().toIso8601String(),
    };
    final MessageSearch messageSearch = MessageSearch.init(
      null,
      messageQl,
      graphQLAuth.getUser().email,
    );
    switch (_messageType) {
      case MessageType.ALL:
        messageSearch.setQueryName('userMessagesReceived');
        messageSearch.setVariables(<String, dynamic>{
          'currentUserEmail': 'String!',
          'status': 'String!',
          'limit': 'String!',
          'cursor': 'String!',
        });
        return messageSearch.getQueryOptions(_values);
        break;
      case MessageType.ATTENTION:
        _values['type'] = 'attention';
        messageSearch.setVariables(<String, dynamic>{
          'currentUserEmail': 'String!',
          'status': 'String!',
          'limit': 'String!',
          'cursor': 'String!',
          'type': 'String!'
        });
        messageSearch.setQueryName('userMessagesByType');

        return messageSearch.getQueryOptions(_values);
        break;
      case MessageType.COMMENT:
        _values['type'] = 'comment';
        messageSearch.setVariables(<String, dynamic>{
          'currentUserEmail': 'String!',
          'status': 'String!',
          'limit': 'String!',
          'cursor': 'String!',
          'type': 'String!'
        });
        messageSearch.setQueryName('userMessagesByType');
        return messageSearch.getQueryOptions(_values);
        break;
      case MessageType.MESSAGE:
        _values['type'] = 'message';
        messageSearch.setVariables(<String, dynamic>{
          'currentUserEmail': 'String!',
          'status': 'String!',
          'limit': 'String!',
          'cursor': 'String!',
          'type': 'String!'
        });
        messageSearch.setQueryName('userMessagesByType');
        return messageSearch.getQueryOptions(_values);
        break;
      case MessageType.FRIEND_REQUEST:
        _values['type'] = 'friend-request';
        messageSearch.setVariables(<String, dynamic>{
          'currentUserEmail': 'String!',
          'status': 'String!',
          'limit': 'String!',
          'cursor': 'String!',
          'type': 'String!'
        });
        messageSearch.setQueryName('userMessagesByType');
        return messageSearch.getQueryOptions(_values);
        break;
      case MessageType.BOOK:
        _values['type'] = 'book';
        messageSearch.setVariables(<String, dynamic>{
          'currentUserEmail': 'String!',
          'status': 'String!',
          'limit': 'String!',
          'cursor': 'String!',
          'type': 'String!'
        });
        messageSearch.setQueryName('userMessagesByType');
        return messageSearch.getQueryOptions(_values);
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    graphQLClient = GraphQLProvider.of(context).value;
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
      drawer: DrawerWidget(),
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

                final List<dynamic> messages = List<dynamic>.from(
                    result.data[searchResultsName[_messageType.index]]);

                if (messages.isEmpty || messages.length < nMessages) {
                  moreSearchResults[_messageType.index] = false;
                }
                if (messages.isNotEmpty) {
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
