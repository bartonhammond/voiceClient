import 'dart:io' as io;
import 'package:MyFamilyVoice/services/email_secure_store.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:MyFamilyVoice/common_widgets/drawer_widget.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/keys.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/constants/transparent_image.dart';
import 'package:MyFamilyVoice/services/eventBus.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/host.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;
import 'package:uuid/uuid.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key key,
    this.id,
    this.onPush,
  }) : super(key: key);
  final ValueChanged<String> onPush;
  final String id;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String userId = '';
  String userEmail = '';
  String name = '';
  String cityState = '';
  String userImage = '';
  bool shouldCreateUser = true;

  Map<String, dynamic> user;
  io.File _image;
  bool imageUpdated = false;
  String imageFilePath;
  final picker = ImagePicker();
  bool _uploadInProgress = false;
  bool formReady = false;

  TextEditingController nameFormFieldController;

  TextEditingController homeFormFieldController;

  @override
  void initState() {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    user = graphQLAuth.getUserMap();
    setState(() {
      if (user != null) {
        shouldCreateUser = false;
        userEmail = user['email'];
        userId = user['id'];
        name = user['name'];
        cityState = user['home'];
        userImage = user['image'];
      } else {
        shouldCreateUser = true;
        final _uuid = Uuid();
        userId = _uuid.v1();
      }
    });

    nameFormFieldController = TextEditingController(text: name);
    homeFormFieldController = TextEditingController(text: cityState);

    nameFormFieldController.addListener(() {
      setState(() {
        name = nameFormFieldController.text;
      });
      _formReady();
    });
    homeFormFieldController.addListener(() {
      setState(() {
        cityState = homeFormFieldController.text;
      });
      _formReady();
    });

    super.initState();
  }

  @override
  void dispose() {
    nameFormFieldController.dispose();
    homeFormFieldController.dispose();

    super.dispose();
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
          imageUpdated = true;
          _image = croppedFile;
        });
        _formReady();
      }
    }
  }

  void _formReady() {
    if (shouldCreateUser) {
      if (_image != null &&
          name != null &&
          name.length > 5 &&
          cityState != null &&
          cityState.length > 1) {
        setState(() {
          formReady = true;
        });
      } else {
        setState(() {
          formReady = false;
        });
      }
    } else {
      if ((name != null && name != user['name'] && name.length > 5) ||
          (cityState != null &&
              cityState != user['home'] &&
              cityState.length > 1) ||
          (_image != null)) {
        setState(() {
          formReady = true;
        });
      } else {
        setState(() {
          formReady = false;
        });
      }
    }
  }

  Widget _buildImageControls() {
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    int _fontSize = 16;
    int _size = 15;
    int _width = 8;
    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
      case DeviceScreenType.mobile:
        break;
      case DeviceScreenType.watch:
        _size = 15;
        _width = 8;
        _fontSize = 12;
        break;

      default:
    }
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          CustomRaisedButton(
            fontSize: _fontSize.toDouble(),
            key: Key(Keys.storyPageGalleryButton),
            text: Strings.galleryImageButton.i18n,
            icon: Icon(
              Icons.photo_library,
              color: Colors.white,
              size: _size.toDouble(),
            ),
            onPressed: () => selectImage(ImageSource.gallery),
          ),
          SizedBox(
            width: _width.toDouble(),
          ),
          CustomRaisedButton(
            fontSize: _fontSize.toDouble(),
            key: Key(Keys.storyPageCameraButton),
            text: Strings.cameraImageButton.i18n,
            icon: Icon(
              Icons.camera,
              color: Colors.white,
              size: _size.toDouble(),
            ),
            onPressed: () => selectImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    int _fontSize = 16;
    int _size = 20;
    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
      case DeviceScreenType.mobile:
        break;
      case DeviceScreenType.watch:
        _size = 20;
        _fontSize = 12;
        break;

      default:
    }
    return _uploadInProgress
        ? CircularProgressIndicator()
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomRaisedButton(
                fontSize: _fontSize.toDouble(),
                key: Key(Keys.profilePageCancelButton),
                icon: Icon(
                  Icons.file_upload,
                  color: Colors.white,
                  size: _size.toDouble(),
                ),
                text: Strings.cancel.i18n,
                onPressed: !formReady
                    ? null
                    : () async {
                        setState(() {
                          nameFormFieldController.text = name;
                          homeFormFieldController.text = cityState;
                          _image = null;
                          formReady = false;
                          _uploadInProgress = false;
                        });
                      },
              ),
              SizedBox(
                width: 15,
              ),
              CustomRaisedButton(
                fontSize: _fontSize.toDouble(),
                key: Key(Keys.profilePageUploadButton),
                icon: Icon(
                  Icons.file_upload,
                  color: Colors.white,
                  size: _size.toDouble(),
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
              )
            ],
          );
  }

  Future<void> doUploads(BuildContext context) async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    String jpegPathUrl;
    try {
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
      final EmailSecureStore emailSecureStore =
          Provider.of<EmailSecureStore>(context, listen: false);
      final QueryResult queryResult = await createOrUpdateUserInfo(
        emailSecureStore,
        shouldCreateUser,
        graphQLClientFileServer,
        graphQLClient,
        jpegPathUrl: jpegPathUrl == null ? userImage : jpegPathUrl,
        id: userId,
        name: name,
        home: cityState,
      );
      if (queryResult.hasException) {
        logger.createMessage(
          userEmail: graphQLAuth.getUser().email,
          source: 'profile_page',
          shortMessage: queryResult.exception.toString(),
          stackTrace: StackTrace.current.toString(),
        );
        throw queryResult.exception;
      }
      await graphQLAuth.setupEnvironment();

      //This enables the other tabs
      eventBus.fire(ProfileEvent(true));

      Flushbar<dynamic>(
        message: Strings.saved.i18n,
        duration: Duration(seconds: 3),
      )..show(_scaffoldKey.currentContext);
    } catch (e) {
      logger.createMessage(
          userEmail: graphQLAuth.getUser().email,
          source: 'profile_page',
          shortMessage: e.exception.toString(),
          stackTrace: StackTrace.current.toString());
      rethrow;
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    int _width = 100;
    int _height = 200;
    int _formFieldWidth = 100;
    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        _width = _height = 50;
        _formFieldWidth = 500;
        break;
      case DeviceScreenType.watch:
        _width = _height = 50;
        _formFieldWidth = 300;
        break;
      case DeviceScreenType.mobile:
        _width = _height = 80;
        _formFieldWidth = 400;
        break;
      default:
        _width = _height = 100;
    }
    return Scaffold(
      key: _scaffoldKey,
      drawer: getDrawer(context),
      appBar: AppBar(
        title: Text(Strings.profilePageName.i18n),
        backgroundColor: Color(0xff00bcd4),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 7.0,
            ),
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(40.0),
                child: Image.file(
                  _image,
                  width: _width.toDouble(),
                  height: _height.toDouble(),
                ),
              )
            else if (userId != null &&
                userId.isNotEmpty &&
                user != null &&
                user['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: FadeInImage.memoryNetwork(
                  height: _width.toDouble(),
                  width: _width.toDouble(),
                  placeholder: kTransparentImage,
                  image: host(
                    user['image'],
                    width: _width,
                    height: _height,
                    resizingType: 'fill',
                    enlarge: 1,
                  ),
                ),
              )
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(
              height: 5,
            ),
            _buildImageControls(),
            SizedBox(
              height: 5,
            ),
            Container(
              width: _formFieldWidth.toDouble(),
              margin: const EdgeInsets.only(right: 10, left: 10),
              child: TextFormField(
                controller: nameFormFieldController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Color(0xff00bcd4),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Color(0xff00bcd4),
                      width: 2.0,
                    ),
                  ),
                  hintStyle: TextStyle(color: Color(0xff00bcd4)),
                  border: const OutlineInputBorder(),
                  filled: true,
                  hintText: Strings.yourFullNameText.i18n,
                  labelText: Strings.yourFullNameLabel.i18n,
                  labelStyle: TextStyle(color: Color(0xff00bcd4)),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return Strings.nameEmptyMessage.i18n;
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              width: _formFieldWidth.toDouble(),
              margin: const EdgeInsets.only(right: 10, left: 10),
              child: TextFormField(
                controller: homeFormFieldController,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: Color(0xff00bcd4),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: Color(0xff00bcd4),
                        width: 2.0,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                    hintText: Strings.yourHomeText.i18n,
                    hintStyle: TextStyle(color: Color(0xff00bcd4)),
                    labelText: Strings.yourHomeLabel.i18n,
                    labelStyle: TextStyle(color: Color(0xff00bcd4))),
                validator: (value) {
                  if (value.isEmpty) {
                    return Strings.homeEmptyMessage.i18n;
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
