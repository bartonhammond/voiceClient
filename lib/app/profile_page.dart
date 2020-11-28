import 'dart:io' as io;
import 'dart:typed_data';
import 'package:MyFamilyVoice/app_config.dart';
import 'package:MyFamilyVoice/web/crop_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:http_parser/http_parser.dart';

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
  bool shouldCreateUser = false;
  bool _loadingFilePickerWeb = false;

  Map<String, dynamic> user;
  io.File _image;
  bool imageUpdated = false;
  String imageFilePath;
  final picker = ImagePicker();
  bool _uploadInProgress = false;
  bool formReady = false;
  ByteData _webImageBytes;

  TextEditingController emailFormFieldController;
  TextEditingController nameFormFieldController;
  TextEditingController homeFormFieldController;

  Map getUser() {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    if (graphQLAuth.getUserMap() == null) {
      return <String, dynamic>{
        'id': '',
        'email': graphQLAuth.user.email,
        'image': '',
        'audio': '',
        'home': '',
      };
    }
    return graphQLAuth.getUserMap();
  }

  void callBack(ByteData imageBytes) {
    setState(() {
      imageUpdated = true;
      _webImageBytes = imageBytes;
      print(_webImageBytes.buffer.asUint8List(0, _webImageBytes.lengthInBytes));
    });
    _formReady();
  }

  @override
  void initState() {
    user = getUser();
    userEmail = user['email'];
    userId = user['id'];
    name = user['name'];
    cityState = user['home'];
    userImage = user['image'];

    //if user is new, id will be empty
    if (userId == null || userId.isEmpty) {
      userId = Uuid().v1();
      shouldCreateUser = true;
    }

    emailFormFieldController = TextEditingController(text: userEmail);
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
    emailFormFieldController.dispose();
    nameFormFieldController.dispose();
    homeFormFieldController.dispose();

    super.dispose();
  }

  Future<void> _openFileExplorer() async {
    List<PlatformFile> _paths;

    setState(() => _loadingFilePickerWeb = true);
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      ))
          ?.files;
    } on PlatformException catch (e) {
      print('Unsupported operation' + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) {
      return;
    }
    //print('bytes: ${_paths[0].bytes}');
    setState(() {
      _loadingFilePickerWeb = false;
    });
    if (_paths != null) {
      Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => CropWidget(
              imageBytes: _paths[0].bytes,
              onCropped: callBack,
            ),
            fullscreenDialog: false,
          ));
    }
    return;
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
    final bool isWeb = AppConfig.of(context).isWeb;
    if (shouldCreateUser) {
      if (((isWeb && _webImageBytes != null) || (!isWeb && _image != null)) &&
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
      if (((isWeb && _webImageBytes != null) || (!isWeb && _image != null)) &&
              (name != null && name.length > 5 && name != user['name']) ||
          (cityState != null &&
              cityState.length > 1 &&
              cityState != user['home'])) {
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

  Widget _buildImageControls(bool isWeb) {
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
    return Row(
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
          onPressed: () =>
              isWeb ? _openFileExplorer() : selectImage(ImageSource.gallery),
        ),
        SizedBox(
          width: _width.toDouble(),
        ),
        isWeb
            ? Container()
            : CustomRaisedButton(
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
    final bool isWeb = AppConfig.of(context).isWeb;

    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);

    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    String jpegPathUrl;

    try {
      if (imageUpdated) {
        MultipartFile multipartFile;
        if (isWeb && _webImageBytes != null) {
          multipartFile = MultipartFile.fromBytes(
              'image',
              _webImageBytes.buffer
                  .asUint8List(0, _webImageBytes.lengthInBytes),
              filename: '$userId.jpg',
              contentType: MediaType('image', 'jpeg'));
        } else {
          multipartFile = getMultipartFile(
            _image,
            '$userId.jpg',
            'image',
            'jpeg',
          );
        }

        jpegPathUrl = await performMutation(
          graphQLClientFileServer,
          multipartFile,
          'jpeg',
        );
      }
      final QueryResult queryResult = await createOrUpdateUserInfo(
        shouldCreateUser,
        graphQLClientFileServer,
        graphQLClient,
        jpegPathUrl: jpegPathUrl == null ? userImage : jpegPathUrl,
        id: userId,
        email: userEmail,
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

  Widget getForm(bool isWeb) {
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    int _width = 100;
    int _height = 200;
    int _formFieldWidth = 100;
    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        _width = _height = 250;
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
        if (isWeb) {
          _width = _height = 250;
        } else {
          _width = _height = 100;
        }
    }
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
          else if (_webImageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: Image.memory(
                _webImageBytes.buffer.asUint8List(
                    _webImageBytes.offsetInBytes, _webImageBytes.lengthInBytes),
                width: _width.toDouble(),
                height: _height.toDouble(),
              ),
            )
          else if (userId != null &&
              userId.isNotEmpty &&
              user != null &&
              user['image'] != null &&
              user['image'].isNotEmpty)
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
          _buildImageControls(isWeb),
          SizedBox(
            height: 5,
          ),
          Container(
            width: _formFieldWidth.toDouble(),
            margin: const EdgeInsets.only(right: 10, left: 10),
            child: TextFormField(
              controller: emailFormFieldController,
              readOnly: true,
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
                labelText: Strings.emailLabel.i18n,
                labelStyle: TextStyle(color: Color(0xff00bcd4)),
              ),
            ),
          ),
          SizedBox(
            height: 15,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = AppConfig.of(context).isWeb;
    return Scaffold(
      key: _scaffoldKey,
      drawer: getDrawer(context),
      appBar: AppBar(
        title: Text(Strings.profilePageName.i18n),
        backgroundColor: Color(0xff00bcd4),
      ),
      body: isWeb && _loadingFilePickerWeb
          ? Center(
              child: const CircularProgressIndicator(),
            )
          : getForm(isWeb),
    );
  }
}
