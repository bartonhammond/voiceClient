import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:voiceClient/app/sign_in/custom_raised_button.dart';
import 'package:voiceClient/common_widgets/recorder_widget.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/constants/transparent_image.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/mutation_service.dart';
import 'package:voiceClient/services/service_locator.dart';

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
  final picker = ImagePicker();
  var uuid = Uuid();

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
        backgroundColor: Color(0xff00bcd4),
        title: Text(
          Strings.MFV.i18n,
        ),
      ),
      //drawer: getDrawer(context),
      body: _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        if (widget.params['id'] != null && widget.params['id'].isNotEmpty)
          FadeInImage.memoryNetwork(
            height: 300,
            width: 300,
            placeholder: kTransparentImage,
            image:
                'http://192.168.1.39:4002/storage/${widget.params['id']}.jpg',
          )
        else if (_image != null)
          Flexible(
            flex: 2,
            child: Image.file(
              _image,
              width: 300,
              height: 300,
            ),
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
                    Strings.imagePlaceholder.i18n,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              ],
            ),
          ),
        SizedBox(
          height: 8,
        ),
        widget.params['id'] == null || widget.params['id'].isEmpty
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
        _buildImageControls(),
        SizedBox(
          height: 8,
        ),
        widget.params['id'] == null || widget.params['id'].isEmpty
            ? Text(
                Strings.audioControls.i18n,
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : SizedBox(
                height: 0,
              ),
        widget.params['id'] == null || widget.params['id'].isEmpty
            ? SizedBox(
                height: 8,
              )
            : SizedBox(
                height: 0,
              ),
        RecorderWidget(
          id: widget.params['id'],
          setAudioFile: setAudioFile,
        ),
        if (_image != null && _audio != null) _buildUploadButton(context)
      ],
    );
  }

  Widget _buildImageControls() {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          CustomRaisedButton(
            key: Key(Keys.storyPageGalleryButton),
            text: Strings.pictureGallery.i18n,
            icon: Icon(
              Icons.photo_library,
              color: Colors.white,
            ),
            onPressed: () => selectImage(ImageSource.gallery),
          ),
          SizedBox(
            width: 8,
          ),
          CustomRaisedButton(
            key: Key(Keys.storyPageCameraButton),
            text: Strings.pictureCamera.i18n,
            icon: Icon(
              Icons.camera,
              color: Colors.white,
            ),
            onPressed: () => selectImage(ImageSource.camera),
          ),
        ],
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
        GraphQLProvider.of(context).value;

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
    return;
  }
}
