import 'package:MyFamilyVoice/app/sign_in/message_button.dart';
import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:MyFamilyVoice/constants/keys.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/constants/transparent_image.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/host.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

class ReactionTable extends StatefulWidget {
  const ReactionTable({@required this.story});
  final Map story;
  @override
  _State createState() => _State();
}

class _State extends State<ReactionTable> {
  @override
  void initState() {
    super.initState();
  }

  ReactionType _filter;

  Future<List> getReactions() async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getStoryReactionsByIdQL),
      variables: <String, dynamic>{
        'id': widget.story['id'],
        'email': graphQLAuth.getUserMap()['email'],
      },
    );

    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    return queryResult.data['storyReactions'];
  }

  @override
  Widget build(BuildContext context) {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
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

  Future<void> _newFriendRequest(String _friendId) async {
    final bool addNewFriend = await PlatformAlertDialog(
      title: Strings.requestFriendship.i18n,
      content: Strings.areYouSure.i18n,
      cancelActionText: Strings.cancel.i18n,
      defaultActionText: Strings.yes.i18n,
    ).show(context);
    if (addNewFriend == true) {
      final _uuid = Uuid();
      try {
        await addUserMessages(
          GraphQLProvider.of(context).value,
          locator<GraphQLAuth>().getCurrentUserId(),
          _friendId,
          _uuid.v1(),
          'new',
          'Friend Request',
          'friend-request',
          null,
        );
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

  Widget getSingleScrollView(List reactions) {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Reactions',
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
                            getCard(reaction),
                          ),
                          reaction['friend']
                              //if friend, do nothing
                              ? DataCell(Text(''))
                              : reaction['userId'] ==
                                      graphQLAuth.getUserMap()['id']
                                  //if its you, do nothing
                                  ? DataCell(
                                      Text(''),
                                    )
                                  //if not a friend
                                  : DataCell(
                                      MessageButton(
                                        key: Key('${Keys.newFriendsButton}'),
                                        text: 'Friend',
                                        onPressed: () {
                                          _newFriendRequest(reaction['userId']);
                                        },
                                        fontSize: 20,
                                        icon: null,
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
              reaction['image'],
              width: 30,
              height: 30,
              resizingType: 'fit',
              enlarge: 0,
            ),
          ),
        ),
      ),
      title: Text(reaction['name']),
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
      child: RaisedButton(
        onPressed: () {
          if (isActive) {
            onButtonClicked(null);
          } else {
            onButtonClicked(type);
          }
        },
        color: Colors.white,
        child: Image.asset(
          asset,
          height: 20,
        ),
      ),
    );
  }
}
