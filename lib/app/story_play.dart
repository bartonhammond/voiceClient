import 'package:flutter/material.dart';

import 'package:graphql/client.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:voiceClient/common_widgets/player_widget.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/strings.dart';

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
                Strings.MFV,
              ),
              backgroundColor: Color(0xff00bcd4),
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
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 5,
          ),
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            story['user']['home'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            story['user']['birth'].toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    int imageHeight = 200;
    int spacer = 8;
    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        imageHeight = 400;
        spacer = 20;
        break;

      default:
        imageHeight = 200;
        spacer = 8;
    }
    return Card(
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            buildFriend(story),
            SizedBox(
              height: spacer.toDouble(),
            ),
            FadeInImage.memoryNetwork(
              height: imageHeight.toDouble(),
              placeholder: kTransparentImage,
              image: 'http://192.168.1.39:4002/storage/${widget.id}.jpg',
            ),
            SizedBox(
              height: spacer.toDouble(),
            ),
            PlayerWidget(
                url: 'http://192.168.1.39:4002/storage/${widget.id}.mp3'),
          ],
        ));
  }
}
