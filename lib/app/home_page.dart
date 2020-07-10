import 'dart:async';
import 'dart:io' as io;

import 'package:audioplayers/audioplayers.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:voiceClient/common_widgets/platform_alert_dialog.dart';
import 'package:voiceClient/common_widgets/platform_exception_alert_dialog.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/services/auth_service.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/service_locator.dart';
import 'package:voiceClient/constants/enums.dart';

const String uploadFile = r'''
mutation($file: Upload!) {
  upload(file: $file)
}
''';

class HomePage extends StatefulWidget {
  HomePage({LocalFileSystem localFileSystem})
      // ignore: unnecessary_this
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();
  final LocalFileSystem localFileSystem;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  io.File _image;
  io.File _file;
  bool _uploadInProgress = false;
  final picker = ImagePicker();
  var uuid = Uuid();

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

  Future<void> _signOut(BuildContext context) async {
    try {
      final AuthService auth = Provider.of<AuthService>(context, listen: false);
      await auth.signOut();
    } on PlatformException catch (e) {
      await PlatformExceptionAlertDialog(
        title: Strings.logoutFailed,
        exception: e,
      ).show(context);
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool didRequestSignOut = await PlatformAlertDialog(
      title: Strings.logout,
      content: Strings.logoutAreYouSure,
      cancelActionText: Strings.cancel,
      defaultActionText: Strings.logout,
    ).show(context);
    if (didRequestSignOut == true) {
      _signOut(context);
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
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('My Family Voice'),
            decoration: BoxDecoration(
              color: NeumorphicTheme.currentTheme(context).variantColor,
            ),
          ),
          ListTile(
            title: Text('Log out'),
            onTap: () {
              _confirmSignOut(context);
            },
          ),
        ],
      )),
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
          if (_image != null)
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
          Text(
            'Image Selection',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8,
          ),
          Flexible(
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
          ),
          _buildAudioControls(),
          if (_image != null && _file != null) _buildUploadButton()
        ],
      ),
    );
  }

  NeumorphicButton _buildUploadButton() {
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
          _uploadInProgress = false;
        });
      },
    );
  }

  Future<void> doUploads(BuildContext context) async {
    MultipartFile multipartFile = getMultipartFile(
      _image,
      '${uuid.v1()}.jpg',
      'image',
      'jpeg',
    );

    await performMutation(multipartFile);

    multipartFile = getMultipartFile(
      _file,
      '${uuid.v1()}.mp4',
      'audio',
      'mp4',
    );

    await performMutation(multipartFile);
    return;
  }

  Future<void> performMutation(MultipartFile multipartFile) async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    final MutationOptions options = MutationOptions(
      documentNode: gql(uploadFile),
      variables: <String, dynamic>{
        'file': multipartFile,
      },
    );

    final GraphQLClient graphQLClient =
        await graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);
    final QueryResult result = await graphQLClient.mutate(options);

    if (result.hasException) {
      print(result.exception.toString());
    }
    return;
  }

  MultipartFile getMultipartFile(
    io.File _file,
    String _fileName,
    String _type,
    String _subType,
  ) {
    final byteData = _file.readAsBytesSync();

    final multipartFile = MultipartFile.fromBytes(
      'photo',
      byteData,
      filename: _fileName,
      contentType: MediaType(_type, _subType),
    );
    return multipartFile;
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
              NeumorphicButton(
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

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString() +
            '.mp4';

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.AAC);

        await _recorder.initialized;
        // after initialization
        final current = await _recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
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
    _file = widget.localFileSystem.file(result.path);
    print('File length: ${await _file.length()}');
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
