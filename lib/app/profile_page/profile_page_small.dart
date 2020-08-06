import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:voiceClient/app/sign_in/custom_raised_button.dart';
import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/constants/transparent_image.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/mutation_service.dart';
import 'package:voiceClient/services/service_locator.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';

class ProfilePageSmall extends StatefulWidget {
  const ProfilePageSmall({
    Key key,
    this.id,
    this.onPush,
  }) : super(key: key);
  final ValueChanged<String> onPush;
  final String id;

  @override
  _ProfilePageSmallState createState() => _ProfilePageSmallState();
}

class _ProfilePageSmallState extends State<ProfilePageSmall> {
  final _formKey = GlobalKey<FormState>();
  String userId = '';
  String name = '';
  String cityState = '';
  int birthYear = 2020;
  Map<String, dynamic> user;
  io.File _image;
  bool imageUpdated = false;
  String imageFilePath;
  final picker = ImagePicker();
  bool _uploadInProgress = false;
  bool formReady = false;
  @override
  void initState() {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    user = graphQLAuth.getUserMap();
    setState(() {
      userId = user['id'];
      name = user['name'];
      cityState = user['home'];
      birthYear = user['birth'];
    });
    super.initState();
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
          formReady = true;
          imageUpdated = true;
          _image = croppedFile;
        });
      }
    }
  }

  Widget _buildImageControls() {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          CustomRaisedButton(
            fontSize: 12,
            key: Key(Keys.storyPageGalleryButton),
            text: Strings.galleryImageButton.i18n,
            icon: Icon(
              Icons.photo_library,
              color: Colors.white,
              size: 15,
            ),
            onPressed: () => selectImage(ImageSource.gallery),
          ),
          SizedBox(
            width: 8,
          ),
          CustomRaisedButton(
            fontSize: 12,
            key: Key(Keys.storyPageCameraButton),
            text: Strings.cameraImageButton.i18n,
            icon: Icon(
              Icons.camera,
              color: Colors.white,
              size: 15,
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
            fontSize: 12,
            key: Key(Keys.profilePageUploadButton),
            icon: Icon(
              Icons.file_upload,
              color: Colors.white,
              size: 20,
            ),
            text: Strings.upload.i18n,
            onPressed: !formReady
                ? null
                : () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      setState(() {
                        _uploadInProgress = true;
                      });
                      await doUploads(context);
                      setState(() {
                        formReady = false;
                        _uploadInProgress = false;
                      });
                    }
                  },
          );
  }

  Future<void> doUploads(BuildContext context) async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    String jpegPathUrl;

    if (imageUpdated) {
      final MultipartFile multipartFile = getMultipartFile(
        _image,
        '$userId.jpg',
        'image',
        'jpeg',
      );

      jpegPathUrl = await performMutation(
        graphQLClientFileServer,
        multipartFile,
        'jpeg',
      );
    }
    final QueryResult queryResult = await updateUserInfo(
      graphQLClientFileServer,
      graphQLClient,
      jpegPathUrl: jpegPathUrl == null ? user['image'] : jpegPathUrl,
      id: user['id'],
      name: name,
      home: cityState,
      birth: birthYear,
    );
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    await graphQLAuth.setupEnvironment();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getDrawer(context),
      appBar: AppBar(
        title: Text(Strings.profilePageName.i18n),
        backgroundColor: Color(0xff00bcd4),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            if (_image != null)
              Container(
                height: 50,
                child: Image.file(_image),
              )
            else if (userId != null && userId.isNotEmpty)
              Container(
                  height: 100,
                  child: FadeInImage.memoryNetwork(
                    height: 300,
                    placeholder: kTransparentImage,
                    image: user['image'],
                  ))
            else
              Flexible(
                flex: 2,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: (MediaQuery.of(context).size.width / 2) - 70,
                      top: 35,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                        child: Image.asset(
                          'assets/user.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Container(
                      height: 100,
                      width: 300,
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
                        Strings.imagePlaceholderText.i18n,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 5,
            ),
            Text(
              Strings.yourPictureSelection.i18n,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            SizedBox(
              height: 5,
            ),
            _buildImageControls(),
            SizedBox(
              height: 5,
            ),
            Container(
              margin: const EdgeInsets.only(right: 10, left: 10),
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                initialValue: name,
                decoration: InputDecoration(
                  labelText: Strings.yourFullNameLabel.i18n,
                  labelStyle: TextStyle(color: Color(0xff00bcd4)),
                ),
                onSaved: (value) {
                  setState(() {
                    name = value;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    formReady = true;
                  });
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return Strings.nameEmptyMessage.i18n;
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              margin: const EdgeInsets.only(right: 5, left: 5),
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                initialValue: cityState,
                decoration: InputDecoration(
                    labelText: Strings.yourHomeLabel.i18n,
                    labelStyle: TextStyle(color: Color(0xff00bcd4))),
                onSaved: (value) {
                  cityState = value;
                },
                onChanged: (value) {
                  setState(() {
                    formReady = true;
                  });
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return Strings.homeEmptyMessage.i18n;
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              margin: const EdgeInsets.only(right: 10, left: 10),
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                initialValue: birthYear.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                    labelText: Strings.yourBirthLabel.i18n,
                    labelStyle: TextStyle(color: Color(0xff00bcd4))),
                onSaved: (dynamic value) {
                  setState(() {
                    birthYear = int.parse(value);
                  });
                },
                onChanged: (value) {
                  setState(() {
                    formReady = true;
                  });
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return Strings.birthEmptyMessage.i18n;
                  }
                  final int _birthYear = int.parse(value);
                  if (_birthYear < 1900 || _birthYear > DateTime.now().year) {
                    return Strings.birthValidationMessage.i18n;
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 8,
            ),
            _buildUploadButton(context)
          ],
        ),
      ),
    );
  }
}
