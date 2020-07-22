import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/common_widgets/staggered_grid_tile_friend.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/service_locator.dart';

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  void run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
    return;
  }
}

class FriendsPage extends StatefulWidget {
  FriendsPage({this.onPush});
  final ValueChanged<String> onPush;
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final String title = 'My Family Voice';
  final nFriends = 20;
  final ScrollController _scrollController = ScrollController();
  String searchString = 'ham';
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    int offset = 0;
    bool shouldBeMore = true;
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    print('friendsPage build');
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
              TextField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(15.0),
                  hintText: 'Filter by name or home',
                ),
                onChanged: (string) {
                  if (string.isEmpty) {
                    return;
                  }
                  _debouncer.run(() {
                    setState(() {
                      searchString = '$string*';
                    });
                  });
                },
              ),
              Query(
                  options: QueryOptions(
                    documentNode: gql(userSearch),
                    variables: <String, dynamic>{
                      'searchString': searchString,
                      'first': nFriends,
                      'offset': offset
                      // set cursor to null so as to start at the beginning
                      // 'cursor': 10
                    },
                  ),
                  builder: (QueryResult result,
                      {refetch, FetchMore fetchMore}) {
                    print('friendsPage queryResult: $result');
                    if (result.loading && result.data == null) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (result.hasException) {
                      return Text(
                          '\nErrors: \n  ' + result.exception.toString());
                    }

                    final List<dynamic> friends = result.data['userSearch'];
                    if (result.data.length < nFriends) {
                      shouldBeMore = false;
                    }
                    offset += nFriends;

                    final FetchMoreOptions opts = FetchMoreOptions(
                      variables: <String, dynamic>{'offset': offset},
                      updateQuery: (dynamic previousResultData,
                          dynamic fetchMoreResultData) {
                        // this is where you combine your previous data and response
                        // in this case, we want to display previous repos plus next repos
                        // so, we combine data in both into a single list of repos
                        final List<dynamic> repos = <dynamic>[
                          ...previousResultData['userSearch'],
                          ...fetchMoreResultData['userSearch'],
                        ];

                        fetchMoreResultData['userSearch'] = repos;

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
                      child: friends == null
                          ? Text('no data')
                          : StaggeredGridView.countBuilder(
                              controller: _scrollController,
                              itemCount: friends.length,
                              primary: false,
                              crossAxisCount: 4,
                              mainAxisSpacing: 4.0,
                              crossAxisSpacing: 4.0,
                              itemBuilder: (context, index) =>
                                  StaggeredGridTileFriend(
                                onPush: widget.onPush,
                                friend:
                                    Map<String, dynamic>.from(friends[index]),
                              ),
                              staggeredTileBuilder: (index) =>
                                  StaggeredTile.fit(2),
                            ),
                    );
                  })
            ],
          ),
        ));
  }
}
