import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:voiceClient/app/sign_in/custom_raised_button.dart';
import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/constants/transparent_image.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/mutation_service.dart';
import 'package:voiceClient/services/service_locator.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key key,
    this.id,
    this.onPush,
  }) : super(key: key);
  final ValueChanged<String> onPush;
  final String id;

  @override
  _FormWidgetsDemoState createState() => _FormWidgetsDemoState();
}

class _FormWidgetsDemoState extends State<ProfilePage> {
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
            key: Key(Keys.storyPageGalleryButton),
            text: 'Gallery',
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
            text: 'Camera',
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
            key: Key(Keys.profilePageUploadButton),
            icon: Icon(
              Icons.file_upload,
              color: Colors.white,
            ),
            text: 'Upload',
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
                      //pop back to tab for stories
                      //widget.onFinish(true);
                      //Navigator.pop(context);
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
        title: Text('Profile'),
        backgroundColor: NeumorphicTheme.currentTheme(context).variantColor,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            if (_image != null)
              Container(
                height: 150,
                child: Image.file(_image),
              )
            else if (userId != null && userId.isNotEmpty)
              Container(
                  height: 150,
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
                        'Your Image Placeholder',
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
              height: 10,
            ),
            Text(
              'Your picture selection',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            _buildImageControls(),
            SizedBox(
              height: 8,
            ),
            Container(
              margin: const EdgeInsets.only(right: 10, left: 10),
              child: TextFormField(
                initialValue: name,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  filled: true,
                  hintText: 'Enter your full name...',
                  labelText: 'Name',
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
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              margin: const EdgeInsets.only(right: 10, left: 10),
              child: TextFormField(
                initialValue: cityState,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  filled: true,
                  hintText: 'Enter your city, state',
                  labelText: 'Home',
                ),
                onSaved: (value) {
                  cityState = value;
                },
                onChanged: (value) {
                  setState(() {
                    formReady = true;
                  });
                },
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              margin: const EdgeInsets.only(right: 10, left: 10),
              child: TextFormField(
                initialValue: birthYear.toString(),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  final int _birthYear = int.parse(value);
                  if (_birthYear < 1900 || _birthYear > DateTime.now().year) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  filled: true,
                  hintText: 'Birth year',
                  labelText: 'Year of your birth',
                ),
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
