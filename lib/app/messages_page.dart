import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:voiceClient/app/sign_in/friend_button.dart';

import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/common_widgets/staggered_grid_tile_message.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/service_locator.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key key, this.onPush, this.onMessagesCount})
      : super(key: key);
  final ValueChanged<String> onPush;
  final VoidCallback onMessagesCount;

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final String title = 'My Family Voice';
  final nMessages = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int offset = 0;
    bool shouldBeMore = true;
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    print('messagesPage build');
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
                  builder: (QueryResult result,
                      {refetch, FetchMore fetchMore}) {
                    print('MessagesPage queryResult: $result');
                    if (result.loading && result.data == null) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (result.hasException) {
                      return Text(
                          '\nErrors: \n  ' + result.exception.toString());
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

                        fetchMoreResultData['User'][0]['messages']['from'] =
                            repos;

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
                                onPush: widget.onPush,
                                message: Map<String, dynamic>.from(
                                  messages[index],
                                ),
                                approveFriendButton: FriendButton(
                                  key: Key(Keys.approveFriendRequestButton),
                                  text: 'Approve',
                                  onPressed: null,
                                ),
                                rejectFriendButton: FriendButton(
                                  key: Key(Keys.rejectFriendRequestButton),
                                  text: 'Reject',
                                  onPressed: null,
                                ),
                              ),
                            ),
                    );
                  })
            ],
          ),
        ));
  }
}
