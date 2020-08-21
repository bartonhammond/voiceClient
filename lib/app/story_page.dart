import 'dart:async';
import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';

import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';

import 'package:voiceClient/app/sign_in/custom_raised_button.dart';
import 'package:voiceClient/common_widgets/image_controls.dart';
import 'package:voiceClient/common_widgets/recorder_widget.dart';
import 'package:voiceClient/common_widgets/tags.dart';
import 'package:voiceClient/constants/constants.dart';
import 'package:voiceClient/constants/enums.dart';

import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/constants/transparent_image.dart';

import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/graphql_client.dart';
import 'package:voiceClient/services/host.dart';
import 'package:voiceClient/services/mutation_service.dart';
import 'package:voiceClient/services/service_locator.dart';
import 'package:voiceClient/services/user_tag_counts.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({Key key, this.params}) : super(key: key);

  final Map<String, dynamic> params;

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  io.File _image;
  io.File _audio;
  bool _uploadInProgress = false;

  var uuid = Uuid();
  List<String> _allTags = <String>[];
  List<String> _tags = <String>[];

  String _imageFilePath;
  String _audioFilePath;

  @override
  void initState() {
    super.initState();
  }

  void setAudioFile(io.File audio) {
    setState(() {
      _audio = audio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserHashtagCounts(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          _allTags = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xff00bcd4),
              title: Text(
                Strings.MFV.i18n,
              ),
            ),
            body: _buildPage(context),
          );
        }
      },
    );
  }

  Widget _buildPage(BuildContext context) {
    final ImageControls _imageControls =
        ImageControls(onImageSelected: (File croppedFile) {
      setState(() {
        _image = croppedFile;
      });
    });

    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    int _width = 100;
    int _height = 200;
    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        _width = _height = 550;
        break;
      case DeviceScreenType.watch:
        _width = _height = 200;
        break;
      case DeviceScreenType.mobile:
        _width = _height = 300;
        break;
      default:
        _width = _height = 100;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          margin: EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.params != null &&
                  widget.params['id'] != null &&
                  widget.params['id'].isNotEmpty)
                Container(
                    margin: EdgeInsets.all(0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: FadeInImage.memoryNetwork(
                          height: _height.toDouble(),
                          width: _width.toDouble(),
                          placeholder: kTransparentImage,
                          image: host('/storage/${widget.params['id']}.jpg)'),
                        )))
              else if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(75.0),
                  child: Image.file(
                    _image,
                    width: _width.toDouble(),
                    height: _height.toDouble(),
                  ),
                )
              else
                Stack(
                  children: <Widget>[
                    Image(
                      image: AssetImage('assets/placeholder.png'),
                      width: _width.toDouble(),
                      height: _height.toDouble(),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: Container(
                        height: _height.toDouble(),
                        width: _width.toDouble(),
                        padding: EdgeInsets.all(5.0),
                        alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Colors.black.withAlpha(30),
                              Colors.black12,
                              Colors.black54
                            ],
                          ),
                        ),
                        child: Text(
                          Strings.imagePlaceholder.i18n,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              SizedBox(
                height: 8,
              ),
              widget.params == null ||
                      widget.params['id'] == null ||
                      widget.params['id'].isEmpty
                  ? Text(
                      Strings.imageSelection.i18n,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              SizedBox(
                height: 8,
              ),
              if (_image != null && _audio != null) _buildUploadButton(context),
              if (_image != null && _audio != null)
                SizedBox(
                  height: 8,
                ),
              _imageControls.buildImageControls(),
              SizedBox(
                height: 8,
              ),
              widget.params == null ||
                      widget.params['id'] == null ||
                      widget.params['id'].isEmpty
                  ? Text(
                      Strings.audioControls.i18n,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              widget.params == null ||
                      widget.params['id'] == null ||
                      widget.params['id'].isEmpty
                  ? SizedBox(
                      height: 8,
                    )
                  : SizedBox(
                      height: 0,
                    ),
              RecorderWidget(
                id: UniqueKey().toString(),
                setAudioFile: setAudioFile,
              ),
              TagsWidget(
                allTags: _allTags,
                tags: _tags,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return _uploadInProgress
        ? CircularProgressIndicator()
        : CustomRaisedButton(
            key: Key(Keys.storyPageUploadButton),
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
                _image = null;
                _audio = null;
                _uploadInProgress = false;
              });
              //pop back to tab for stories

              Navigator.pop(context);
            },
          );
  }

  Future<void> doUploads(BuildContext context) async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    final GraphQLClient graphQLClientApolloServer =
        getGraphQLClient(context, GraphQLClientType.ApolloServer);

    final String _id = uuid.v1();
    MultipartFile multipartFile = getMultipartFile(
      _image,
      '$_id.jpg',
      'image',
      'jpeg',
    );

    _imageFilePath = await performMutation(
      graphQLClientFileServer,
      multipartFile,
      'jpeg',
    );

    multipartFile = getMultipartFile(
      _audio,
      '$_id.mp3',
      'audio',
      'mp3',
    );

    _audioFilePath = await performMutation(
      graphQLClientFileServer,
      multipartFile,
      'mp3',
    );

    await addStory(
      graphQLClientApolloServer,
      graphQLAuth.getCurrentUserId(),
      _id,
      _imageFilePath,
      _audioFilePath,
      daysOffset: 0,
    );

    _tags = _tags.toSet().toList();

    for (var tag in _tags) {
      await addHashTag(
        graphQLClientApolloServer,
        tag,
      );
      await addStoryHashtags(
        graphQLClientApolloServer,
        _id,
        tag,
      );
    }
    return;
  }
}
