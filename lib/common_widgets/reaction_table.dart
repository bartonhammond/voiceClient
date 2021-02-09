import 'package:MyFamilyVoice/app/sign_in/message_button.dart';
import 'package:MyFamilyVoice/common_widgets/friend_message_page.dart';
import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/constants/transparent_image.dart';
import 'package:MyFamilyVoice/ql/reaction/reaction_search.dart';
import 'package:MyFamilyVoice/ql/reaction_ql.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/host.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

class ReactionTable extends StatefulWidget {
  const ReactionTable({@required this.story});
  final Map story;
  @override
  _State createState() => _State();
}

class _State extends State<ReactionTable> {
  ReactionQl reactionQl;
  @override
  void initState() {
    super.initState();

    reactionQl = ReactionQl();
  }

  ReactionType _filter;
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

  Future<List> getReactions() async {
    final ReactionSearch reactionSearch = ReactionSearch.init(
      null,
      reactionQl,
      graphQLAuth.getUserMap()['email'],
    );

    reactionSearch.setVariables(
      <String, dynamic>{
        'id': 'String!',
        'currentUserEmail': 'String!',
      },
    );

    final Map values = <String, dynamic>{
      'id': widget.story['id'],
      'currentUserEmail': graphQLAuth.getUserMap()['email'],
    };

    reactionSearch.setQueryName('storyReactions');
    return await reactionSearch.getListFromQuery(
      GraphQLProvider.of(context).value,
      values,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getReactions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logger.createMessage(
                userEmail: graphQLAuth.getUser().email,
                source: 'stories_page',
                shortMessage: snapshot.error.toString(),
                stackTrace: StackTrace.current.toString());
            return Text('\nErrors: \n  ' + snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final List reactions = snapshot.data;
          return getSingleScrollView(reactions);
        });
  }

  void onButtonClicked(ReactionType type) {
    setState(() {
      _filter = type;
    });
  }

  Future<void> _newFriendRequest(Map<String, dynamic> reaction) async {
    final bool addNewFriend = await PlatformAlertDialog(
      key: Key('reactionTableFriendRequest'),
      title: Strings.requestFriendship.i18n,
      content: Strings.areYouSure.i18n,
      cancelActionText: Strings.cancel.i18n,
      defaultActionText: Strings.yes.i18n,
    ).show(context);
    if (addNewFriend == true) {
      final _uuid = Uuid();
      try {
        await addUserMessages(
          graphQLClient: GraphQLProvider.of(context).value,
          fromUser: graphQLAuth.getUserMap(),
          toUser: reaction['from'],
          messageId: _uuid.v1(),
          status: 'new',
          type: 'friend-request',
          key: null,
        );
        setState(() {});
      } catch (e) {
        logger.createMessage(
            userEmail: graphQLAuth.getUser().email,
            source: 'reaction_table',
            shortMessage: e.toString(),
            stackTrace: StackTrace.current.toString());
        rethrow;
      }
    }
    return;
  }

  bool isFriend(Map reaction) {
    if (reaction['from']['friendsTo'] != null) {
      for (var _reaction in reaction['from']['friendsTo']) {
        if (_reaction['receiver']['email'] == graphQLAuth.getUser().email) {
          return true;
        }
      }
    }
    return false;
  }

  bool isPendingFriendRequest(Map reaction) {
    if (reaction['from']['messagesReceived'] != null) {
      for (var _message in reaction['from']['messagesReceived']) {
        if (_message['type'] == 'friend-request' &&
            _message['status'] == 'new' &&
            _message['sender']['email'] == graphQLAuth.getUser().email) {
          return true;
        }
      }
    }
    return false;
  }

  Widget getSingleScrollView(List reactions) {
    const double columnSize = 150;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Strings.reactionTableTitle.i18n,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            buttonHeight: 15,
            buttonMinWidth: 15,
            children: <Widget>[
              //getButton(false, '', 'All  5'),
              widget.story['totalLikes'] > 0
                  ? getButton(
                      ReactionType.LIKE,
                      'assets/images/like.png',
                      _filter == ReactionType.LIKE,
                      widget.story['totalLikes'],
                    )
                  : Container(),
              widget.story['totalHahas'] > 0
                  ? getButton(
                      ReactionType.HAHA,
                      'assets/images/haha.png',
                      _filter == ReactionType.HAHA,
                      widget.story['totalHahas'],
                    )
                  : Container(),
              widget.story['totalJoys'] > 0
                  ? getButton(
                      ReactionType.JOY,
                      'assets/images/joy.png',
                      _filter == ReactionType.JOY,
                      widget.story['totalJoys'],
                    )
                  : Container(),
              widget.story['totalWows'] > 0
                  ? getButton(
                      ReactionType.WOW,
                      'assets/images/wow.png',
                      _filter == ReactionType.WOW,
                      widget.story['totalWows'],
                    )
                  : Container(),
              widget.story['totalSads'] > 0
                  ? getButton(
                      ReactionType.SAD,
                      'assets/images/sad.png',
                      _filter == ReactionType.SAD,
                      widget.story['totalSads'],
                    )
                  : Container(),
              widget.story['totalLoves'] > 0
                  ? getButton(
                      ReactionType.LOVE,
                      'assets/images/love.png',
                      _filter == ReactionType.LOVE,
                      widget.story['totalLoves'],
                    )
                  : Container(),
            ],
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: DataTable(
                headingRowHeight: 0.0,
                sortColumnIndex: 0,
                dataRowHeight: 80.0,
                horizontalMargin: 0.0,
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(''),
                    numeric: false,
                  ),
                  DataColumn(
                    label: Text(''),
                    numeric: false,
                  ),
                ],
                rows: reactions
                    .where((dynamic element) {
                      if (_filter == null) {
                        return true;
                      }
                      return element['type'] == reactionTypes[_filter.index];
                    })
                    .map(
                      (dynamic reaction) => DataRow(
                        cells: [
                          DataCell(
                            Container(
                              width: columnSize,
                              child: getCard(reaction),
                            ),
                          ),
                          isFriend(reaction)
                              //if friend, show message
                              ? DataCell(
                                  Container(
                                    width: columnSize,
                                    child: MessageButton(
                                      key: Key(
                                          'messageButton-message-${reaction["from"]["email"]}'),
                                      text: Strings.reactionTableMessage.i18n,
                                      onPressed: () async {
                                        Navigator.push<dynamic>(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (BuildContext context) =>
                                                  FriendMessagePage(
                                                user: reaction['from'],
                                              ),
                                              fullscreenDialog: false,
                                            ));
                                      },
                                      fontSize: 15,
                                      icon: null,
                                    ),
                                  ),
                                )
                              : reaction['from']['id'] ==
                                      graphQLAuth.getUserMap()['id']
                                  //if its you, do nothing
                                  ? DataCell(
                                      Container(
                                        width: columnSize,
                                        child: Text(''),
                                      ),
                                      placeholder: true)
                                  //if not a friend
                                  : DataCell(
                                      Container(
                                        width: columnSize,
                                        child: MessageButton(
                                          key: Key(
                                              'messageButton-friend-${reaction["from"]["email"]}'),
                                          text: isPendingFriendRequest(reaction)
                                              ? Strings.pending
                                              : Strings.newFriend.i18n,
                                          onPressed:
                                              isPendingFriendRequest(reaction)
                                                  ? null
                                                  : () {
                                                      _newFriendRequest(
                                                        reaction,
                                                      );
                                                    },
                                          fontSize: 20,
                                          icon: null,
                                        ),
                                      ),
                                    ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getCard(Map reaction) {
    String asset = reaction['type'];
    asset = asset.toLowerCase();
    return ListTile(
      isThreeLine: true,
      leading: Container(
        height: 30,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: host(
              reaction['from']['image'],
              width: 30,
              height: 30,
              resizingType: 'fit',
              enlarge: 0,
            ),
          ),
        ),
      ),
      title: AutoSizeText(
        reaction['from']['name'],
        maxLines: 2,
      ),
      subtitle: Image.asset(
        'assets/images/$asset.png',
        height: 20,
      ),
    );
  }

  Widget getButton(
    ReactionType type,
    String asset,
    bool isActive,
    int count,
  ) {
    return Container(
        height: 35,
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(
            width: 3,
            color: isActive ? Color(0xff00bcd4) : Colors.white,
          ),
        )),
        child: TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          onPressed: () {
            if (isActive) {
              onButtonClicked(null);
            } else {
              onButtonClicked(type);
            }
          },
          child: Image.asset(
            asset,
            height: 20,
          ),
        ));
  }
}
