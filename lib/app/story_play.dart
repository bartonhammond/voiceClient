import 'package:flutter/material.dart';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:graphql/client.dart';
import 'package:voiceClient/common_widgets/player_widget.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';

import 'package:voiceClient/constants/transparent_image.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/service_locator.dart';

class StoryPlay extends StatefulWidget {
  const StoryPlay({Key key, this.id}) : super(key: key);

  final String id;

  @override
  _StoryPlayState createState() => _StoryPlayState();
}

class _StoryPlayState extends State<StoryPlay> {
  Map<String, dynamic> story;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getStory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          story = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'My Family Voice',
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
              backgroundColor:
                  NeumorphicTheme.currentTheme(context).variantColor,
            ),
            //drawer: getDrawer(context),
            body: _buildPage(context),
          );
        }
      },
    );
  }

  Future<Map> getStory() async {
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getStoryById),
      variables: <String, dynamic>{'id': widget.id},
    );
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    final GraphQLClient graphQLClient =
        graphQLAuth.getGraphQLClient(GraphQLClientType.ApolloServer);

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    return queryResult.data['Story'][0];
  }

  Widget buildFriend(Map<String, dynamic> story) {
    return Card(
      child: Column(
        children: <Widget>[
          //new Center(child: new CircularProgressIndicator()),
          Center(
            child: GestureDetector(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: FadeInImage.memoryNetwork(
                  height: 75,
                  placeholder: kTransparentImage,
                  image: story['user']['image'],
                ),
              ),
            ),
          ),
          Text(
            story['user']['name'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
          ),
          Text(
            story['user']['home'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
          ),
          Text(
            story['user']['birth'].toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
          )
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Neumorphic(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          buildFriend(story),
          FadeInImage.memoryNetwork(
            height: 300,
            placeholder: kTransparentImage,
            image: 'http://192.168.1.39:4002/storage/${widget.id}.jpg',
          ),
          SizedBox(
            height: 8,
          ),
          PlayerWidget(
              url: 'http://192.168.1.39:4002/storage/${widget.id}.mp3'),
        ],
      ),
    );
  }
}
