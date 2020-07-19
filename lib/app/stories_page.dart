import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/common_widgets/staggered_grid_tile.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/service_locator.dart';

class StoriesPage extends StatelessWidget {
  StoriesPage({this.onPush});
  final ValueChanged<Map> onPush;

  final String title = 'My Family Voice';
  final nActivities = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    int offset = 0;
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    print('storiesPage build');
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
                    documentNode: gql(userActivities),
                    variables: <String, dynamic>{
                      'email': graphQLAuth.getUser().email,
                      'first': nActivities,
                      'offset': offset
                      // set cursor to null so as to start at the beginning
                      // 'cursor': 10
                    },
                  ),
                  builder: (QueryResult result,
                      {refetch, FetchMore fetchMore}) {
                    print('homePage queryResult: $result');
                    if (result.loading && result.data == null) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (result.hasException) {
                      return Text(
                          '\nErrors: \n  ' + result.exception.toString());
                    }

                    final List<dynamic> activities =
                        result.data['User'][0]['activities'];

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
                      child: StaggeredGridView.countBuilder(
                        controller: _scrollController,
                        itemCount: activities.length,
                        primary: false,
                        crossAxisCount: 4,
                        mainAxisSpacing: 4.0,
                        crossAxisSpacing: 4.0,
                        itemBuilder: (context, index) => StaggeredGridTile(
                          onPush: onPush,
                          id: activities[index]['id'],
                          imageUrl: activities[index]['image'],
                          audioUrl: activities[index]['audio'],
                        ),
                        staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                      ),
                    );
                  })
            ],
          ),
        ));
  }
}
