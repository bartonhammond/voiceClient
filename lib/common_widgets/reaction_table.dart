import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:MyFamilyVoice/constants/transparent_image.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/host.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:MyFamilyVoice/common_widgets/reactions.dart' as react;

class ReactionTable extends StatefulWidget {
  const ReactionTable({@required this.story});
  final Map story;
  @override
  _State createState() => _State();
}

class _State extends State<ReactionTable> {
  bool sort;

  @override
  void initState() {
    sort = false;
    super.initState();
  }

  void onSortColum(int columnIndex, bool ascending) {
    /*
    if (columnIndex == 0) {
      if (ascending) {
        avengers.sort((a, b) => a.name.compareTo(b.name));
      } else {
        avengers.sort((a, b) => b.name.compareTo(a.name));
      }
    }
    */
  }

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

  Widget getSingleScrollView(List reactions) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ButtonBar(
            buttonHeight: 15,
            buttonMinWidth: 15,
            // this will take space as minimum as posible(to center)
            children: <Widget>[
              //getButton(false, '', 'All  5'),
              getButton(true, 'assets/images/like.png', false),
              getButton(true, 'assets/images/haha.png', false),
              getButton(true, 'assets/images/joy.png', false),
              getButton(true, 'assets/images/wow.png', false),
              getButton(true, 'assets/images/sad.png', false),
              getButton(true, 'assets/images/love.png', false),
            ],
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: DataTable(
                headingRowHeight: 0.0,
                sortAscending: sort,
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
                    .map(
                      (dynamic reaction) => DataRow(cells: [
                        DataCell(
                          getCard(reaction),
                        ),
                        DataCell(
                          RaisedButton(
                            onPressed: () {},
                            child: const Text('Add Friend',
                                style: TextStyle(fontSize: 15)),
                          ),
                        ),
                      ]),
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
    return ListTile(
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
      react.reactions[reactionTypes
                              .indexOf(reaction['type'])]
      subtitle: Image.asset(
          asset,
          height: 20,
        ),,
    );
  }

  Widget getButton(
    bool withAsset,
    String asset,
    bool isActive,
  ) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(
          width: 3,
          color: isActive ? Colors.green : Colors.white,
        ),
      )),
      child: RaisedButton(
        onPressed: () {},
        child: Image.asset(
          asset,
          height: 20,
        ),
        color: Colors.white,
      ),
    );
  }
}
