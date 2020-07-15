import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:voiceClient/common_widgets/player_widget.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/service_locator.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key}) : super(key: key);

  final String title = 'My Family Voice';

  final nActivities = 20;
  int offset = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    print('homePage build');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Query(
              options: QueryOptions(
                documentNode: gql(userActivities),
                variables: <String, dynamic>{
                  'email': graphQLAuth.getUser().email,
                  'first': nActivities,
                  'offset': offset
                  // set cursor to null so as to start at the beginning
                  // 'cursor': 10
                },
              ),
              builder: (QueryResult result, {refetch, FetchMore fetchMore}) {
                print('homePage queryResult: $result');
                if (result.loading && result.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (result.hasException) {
                  return Text('\nErrors: \n  ' + result.exception.toString());
                }

                final List<dynamic> activities =
                    (result.data['User'][0]['activities'] as List<dynamic>);

                offset += nActivities;

                final FetchMoreOptions opts = FetchMoreOptions(
                  variables: <String, dynamic>{'offset': offset},
                  updateQuery: (dynamic previousResultData,
                      dynamic fetchMoreResultData) {
                    // this is where you combine your previous data and response
                    // in this case, we want to display previous repos plus next repos
                    // so, we combine data in both into a single list of repos
                    final List<dynamic> repos = <dynamic>[
                      ...previousResultData['User'][0]['activities'],
                      ...fetchMoreResultData['User'][0]['activities'],
                    ];

                    fetchMoreResultData['User'][0]['activities'] = repos;

                    return fetchMoreResultData;
                  },
                );

                _scrollController
                  ..addListener(() {
                    if (_scrollController.position.pixels ==
                        _scrollController.position.maxScrollExtent) {
                      if (!result.loading) {
                        fetchMore(opts);
                      }
                    }
                  });

                return Expanded(
                  child: ListView(
                    controller: _scrollController,
                    children: <Widget>[
                      for (var activity in activities)
                        Container(
                            decoration: BoxDecoration(
                              //                    <-- BoxDecoration
                              border: Border(bottom: BorderSide()),
                            ),
                            child: ListTile(
                              leading: Image.network(activity['image']),
                              title: PlayerWidget(url: activity['audio']),
                            )),
                      if (result.loading)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
