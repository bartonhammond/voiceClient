import 'dart:io' as io;
import 'package:http/http.dart';

import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';
import 'package:voiceClient/app/sign_in/custom_raised_button.dart';

import 'package:voiceClient/common_widgets/comments.dart';
import 'package:voiceClient/common_widgets/player_widget.dart';
import 'package:voiceClient/common_widgets/recorder_widget.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/constants/transparent_image.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/mutation_service.dart';
import 'package:voiceClient/services/service_locator.dart';

class StoryPlay extends StatefulWidget {
  const StoryPlay({Key key, this.params}) : super(key: key);
  final Map<String, dynamic> params;

  @override
  _StoryPlayState createState() => _StoryPlayState();
}

class _StoryPlayState extends State<StoryPlay> {
  Map<String, dynamic> story;
  io.File _audio;
  bool _uploadInProgress = false;
  var uuid = Uuid();

  void setAudioFile(io.File audio) {
    setState(() {
      _audio = audio;
    });
  }

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
          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  Strings.MFV,
                ),
                backgroundColor: Color(0xff00bcd4),
                leading: IconButton(
                    icon: Icon(MdiIcons.lessThan),
                    onPressed: () {
                      widget.params['onFinish']();
                      Navigator.of(context).pop('upload');
                    }),
              ),
              //drawer: getDrawer(context),
              body: _buildPage(context),
            ),
          );
        }
      },
    );
  }

  Future<Map> getStory() async {
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getStoryByIdQL),
      variables: <String, dynamic>{'id': widget.params['id']},
    );

    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

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

  Future<void> doUploads(BuildContext context) async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    final GraphQLClient graphQLClientApolloServer =
        GraphQLProvider.of(context).value;

    final String _commentId = uuid.v1();
    final MultipartFile multipartFile = getMultipartFile(
      _audio,
      '$_commentId.mp3',
      'audio',
      'mp3',
    );

    final String _audioFilePath = await performMutation(
      graphQLClientFileServer,
      multipartFile,
      'mp3',
    );

    await createComment(
      graphQLClientApolloServer,
      _commentId,
      story['id'],
      _audioFilePath,
      'new',
    );

    await mergeCommentFrom(
      graphQLClientApolloServer,
      graphQLAuth.getCurrentUserId(),
      _commentId,
    );

    await addStoryComments(
      graphQLClientApolloServer,
      story['id'],
      _commentId,
    );
    return;
  }

  Widget _buildUploadButton(BuildContext context) {
    return _uploadInProgress
        ? CircularProgressIndicator()
        : CustomRaisedButton(
            key: Key(Keys.commentsUploadButton),
            icon: Icon(
              Icons.file_upload,
              color: Colors.white,
            ),
            text: Strings.upload.i18n,
            onPressed: () async {
              setState(() {
                _uploadInProgress = true;
              });
              await doUploads(context);
              setState(() {
                _audio = null;
                _uploadInProgress = false;
              });

              //Navigator.pop(context);
            },
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
              image: story['image'],
            ),
            SizedBox(
              height: spacer.toDouble(),
            ),
            PlayerWidget(
              url: story['audio'],
            ),
            Divider(
              height: spacer.toDouble(),
              thickness: 5,
            ),
            Text('Record a comment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(
              height: spacer.toDouble(),
            ),
            RecorderWidget(
              id: story['id'],
              setAudioFile: setAudioFile,
              timerDuration: 90,
            ),
            if (_audio != null) _buildUploadButton(context),
            Divider(
              height: spacer.toDouble(),
              thickness: 5,
            ),
            Text('Comments',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Comments(
              key: Key(Keys.commentsWidgetExpansionTile),
              story: story,
              fontSize: 16,
              showExpand: true,
            ),
          ],
        ));
  }
}
