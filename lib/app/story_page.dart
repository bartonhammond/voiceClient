import 'dart:async';
import 'dart:io' as io;

import 'package:audioplayers/audioplayers.dart';
import 'package:file/local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:uuid/uuid.dart';

import 'package:voiceClient/constants/transparent_image.dart';
import 'package:voiceClient/services/auth_service.dart';

import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/mutation_service.dart';
import 'package:voiceClient/services/service_locator.dart';
import 'package:voiceClient/constants/enums.dart';

class StoryPage extends StatefulWidget {
  StoryPage({Key key, this.onFinish, this.id}) : super(key: key);

  final LocalFileSystem localFileSystem = LocalFileSystem();
  final String id;
  final ValueChanged<bool> onFinish;

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  io.File _image;
  io.File _audio;
  bool _uploadInProgress = false;
  final picker = ImagePicker();
  var uuid = Uuid();

  String imageFilePath;
  String audioFilePath;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future selectImage(ImageSource source) async {
    io.File image;
    final PickedFile pickedFile = await picker.getImage(source: source);
    if (pickedFile != null) {
      image = io.File(pickedFile.path);
    }

    if (image != null && pickedFile != null) {
      final io.File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        compressQuality: 50,
        maxWidth: 700,
        maxHeight: 700,
        compressFormat: ImageCompressFormat.jpg,
        aspectRatioPresets: io.Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ),
      );

      if (croppedFile != null) {
        setState(() {
          _image = croppedFile;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Family Voice',
          style: TextStyle(color: Colors.black.withOpacity(0.6)),
        ),
        backgroundColor: NeumorphicTheme.currentTheme(context).variantColor,
      ),
      //drawer: getDrawer(context),
      body: _buildPage(context),
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
          if (widget.id != null && widget.id.isNotEmpty)
            FadeInImage.memoryNetwork(
              height: 300,
              placeholder: kTransparentImage,
              image: 'http://192.168.1.39:4002/storage/${widget.id}.jpg',
            )
          else if (_image != null)
            Flexible(
              flex: 9,
              child: Image.file(_image),
            )
          else
            Flexible(
              flex: 2,
              child: Stack(
                children: <Widget>[
                  Image(
                    image: AssetImage('assets/placeholder.png'),
                    width: 300,
                    height: 300,
                  ),
                  Container(
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
                        'Image Placeholder',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ))
                ],
              ),
            ),
          SizedBox(
            height: 8,
          ),
          widget.id == null || widget.id.isEmpty
              ? Text(
                  'Image Selection',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : SizedBox(
                  height: 0,
                ),
          SizedBox(
            height: 8,
          ),
          _buildImageControls(),
          _buildAudioControls(),
          if (_image != null && _audio != null) _buildUploadButton(context)
        ],
      ),
    );
  }

  Widget _buildImageControls() {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          NeumorphicButton(
            style: NeumorphicStyle(
                border: NeumorphicBorder(
              color: Color(0x33000000),
              width: 0.8,
            )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.photo_library),
                SizedBox(
                  width: 5,
                ),
                Text('Gallery'),
              ],
            ),
            onPressed: () => selectImage(ImageSource.gallery),
          ),
          SizedBox(
            width: 8,
          ),
          NeumorphicButton(
            style: NeumorphicStyle(
                border: NeumorphicBorder(
              color: Color(0x33000000),
              width: 0.8,
            )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.camera),
                SizedBox(
                  width: 5,
                ),
                Text('Camera'),
              ],
            ),
            onPressed: () => selectImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  GraphQLClient getGraphQLClient(GraphQLClientType type) {
    const port = '4001';
    const endPoint = 'graphql';
    const url = 'http://192.168.1.39'; //HP
    const uri = '$url:$port/$endPoint';
    final httpLink = HttpLink(uri: uri);

    final AuthService auth = Provider.of<AuthService>(context, listen: false);

    final AuthLink authLink = AuthLink(getToken: () async {
      final IdTokenResult tokenResult = await auth.currentUserIdToken();
      return 'Bearer ${tokenResult.token}';
    });

    final link = authLink.concat(httpLink);

    final GraphQLClient graphQLClient = GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    );

    return graphQLClient;
  }

  NeumorphicButton _buildUploadButton(BuildContext context) {
    return NeumorphicButton(
      style: NeumorphicStyle(
          border: NeumorphicBorder(
        color: Color(0x33000000),
        width: 0.8,
      )),
      child: _isLoadingInProgress(),
      onPressed: () async {
        setState(() {
          _uploadInProgress = true;
        });
        await doUploads(context);
        setState(() {
          _image = null;
          _audio = null;
          _uploadInProgress = false;
          _recorder = null;
          _current = null;
          _currentStatus = RecordingStatus.Initialized;
        });
        //pop back to tab for stories
        widget.onFinish(true);
        Navigator.pop(context);
      },
    );
  }

  Future<void> doUploads(BuildContext context) async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    final GraphQLClient graphQLClientApolloServer =
        getGraphQLClient(GraphQLClientType.ApolloServer);

    final String _id = uuid.v1();
    MultipartFile multipartFile = getMultipartFile(
      _image,
      '$_id.jpg',
      'image',
      'jpeg',
    );

    imageFilePath = await performMutation(
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

    audioFilePath = await performMutation(
      graphQLClientFileServer,
      multipartFile,
      'mp3',
    );

    await addStory(
      graphQLClientApolloServer,
      graphQLAuth.getCurrentUserId(),
      _id,
      imageFilePath,
      audioFilePath,
      daysOffset: 0,
    );
    return;
  }

  Widget _isLoadingInProgress() {
    return _uploadInProgress
        ? CircularProgressIndicator()
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.file_upload),
              SizedBox(
                width: 5,
              ),
              Text('Upload'),
            ],
          );
  }

  Widget _buildAudioControls() {
    return Neumorphic(
      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Audio Controls',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              widget.id == null
                  ? getRecordButton()
                  : SizedBox(
                      width: 0,
                    ),
              SizedBox(
                width: 0,
              ),
              NeumorphicButton(
                style: NeumorphicStyle(
                    border: NeumorphicBorder(
                  color: Color(0x33000000),
                  width: 0.8,
                )),
                onPressed:
                    _currentStatus != RecordingStatus.Unset ? _stop : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.stop),
                    SizedBox(
                      width: 5,
                    ),
                    Text('Stop'),
                  ],
                ),
              ),
              SizedBox(
                width: 4,
              ),
              NeumorphicButton(
                style: NeumorphicStyle(
                    border: NeumorphicBorder(
                  color: Color(0x33000000),
                  width: 0.8,
                )),
                onPressed: onPlayAudio,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.play_circle_outline),
                    SizedBox(
                      width: 5,
                    ),
                    Text('Play'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getRecordButton() {
    return NeumorphicButton(
      style: NeumorphicStyle(
          border: NeumorphicBorder(
        color: Color(0x33000000),
        width: 0.8,
      )),
      onPressed: () {
        switch (_currentStatus) {
          case RecordingStatus.Initialized:
            {
              _start();
              break;
            }
          case RecordingStatus.Recording:
            {
              _pause();
              break;
            }
          case RecordingStatus.Paused:
            {
              _resume();
              break;
            }
          case RecordingStatus.Stopped:
            {
              _init();
              break;
            }
          default:
            break;
        }
      },
      child: _buildText(_currentStatus),
    );
  }

  Future<void> _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        io.Directory appDocDirectory;
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp3" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString() +
            '.mp3';

        // .wav <---> AudioFormat.WAV
        // .mp3 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.AAC);

        await _recorder.initialized;
        // after initialization
        final current = await _recorder.current(channel: 0);
        print('storyPage current: $current');
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print('storyPage _currentStatus: $_currentStatus');
        });
      } else {
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text('You must accept permissions')));
      }
    } catch (e) {
      print(e);
    }
    return;
  }

  Future<void> _start() async {
    try {
      await _recorder.start();
      final recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
      });

      const tick = Duration(milliseconds: 50);
      Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        final current = await _recorder.current(channel: 0);
        // print(current.status);
        setState(() {
          _current = current;
          _currentStatus = _current.status;
        });
      });
    } catch (e) {
      print(e);
    }
    return;
  }

  Future<void> _resume() async {
    await _recorder.resume();
    setState(() {});
    return;
  }

  Future<void> _pause() async {
    await _recorder.pause();
    setState(() {});
    return;
  }

  Future<void> _stop() async {
    final result = await _recorder.stop();
    print('Stop recording: ${result.path}');
    print('Stop recording: ${result.duration}');
    _audio = widget.localFileSystem.file(result.path);
    print('File length: ${await _audio.length()}');
    setState(() {
      _current = result;
      _currentStatus = _current.status;
    });
    return;
  }

  Widget _buildText(RecordingStatus status) {
    var text = '';
    IconData iconData;
    switch (_currentStatus) {
      case RecordingStatus.Initialized:
        {
          text = 'Record';
          iconData = Icons.mic;
          break;
        }
      case RecordingStatus.Recording:
        {
          text = 'Pause';
          iconData = Icons.pause_circle_outline;
          break;
        }
      case RecordingStatus.Paused:
        {
          text = 'Resume';
          iconData = Icons.mic_off;
          break;
        }
      case RecordingStatus.Stopped:
        {
          text = 'Clear';
          iconData = Icons.clear;
          break;
        }
      default:
        break;
    }
    //return Text(text, style: TextStyle(color: Colors.white));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(iconData),
        SizedBox(
          width: 2,
        ),
        Text(text),
      ],
    );
  }

  Future<void> onPlayAudio() async {
    final AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(_current.path, isLocal: true);
    return;
  }
}
