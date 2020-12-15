import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:MyFamilyVoice/app_config.dart';
import 'package:MyFamilyVoice/common_widgets/image_controls.dart';
import 'package:MyFamilyVoice/constants/constants.dart';
import 'package:MyFamilyVoice/services/check_proxy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
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
    this.isBook = false,
  }) : super(key: key);
  final ValueChanged<String> onPush;
  final String id;
  final bool isBook;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _nameFormKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _homeFormKey = GlobalKey<FormFieldState>();
  GraphQLAuth graphQLAuth;
  GraphQLClient graphQLClientFileServer;
  GraphQLClient graphQLClient;
  bool isBook;
  String userId = '';
  String userImage = '';
  bool shouldCreateUser = false;
  bool _isWeb = false;
  Map<String, dynamic> user;
  io.File _image;
  bool imageUpdated = false;
  String imageFilePath;
  final picker = ImagePicker();
  bool _uploadInProgress = false;
  bool formReady = false;
  bool nameIsValid = false;
  bool homeIsValid = false;
  Uint8List _webImage;

  String jpegPathUrl;

  TextEditingController emailFormFieldController = TextEditingController();
  TextEditingController nameFormFieldController = TextEditingController();
  TextEditingController homeFormFieldController = TextEditingController();

  StreamSubscription proxyStartedSubscription;
  StreamSubscription proxyEndedSubscription;

  Future<Map<String, dynamic>> getUser() async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    Map<String, dynamic> user;
    if (widget.isBook) {
      user = <String, dynamic>{
        'id': '',
        'email': '',
        'image': '',
        'audio': '',
        'home': '',
        'isBook': widget.isBook,
        'bookAuthorEmail': ''
      };
    } else if (graphQLAuth.getUserMap() == null) {
      //must be new user
      user = <String, dynamic>{
        'id': '',
        'email': graphQLAuth.user.email,
        'image': '',
        'audio': '',
        'home': '',
        'isBook': false,
        'bookAuthorEmail': ''
      };
    } else {
      //existing user
      graphQLAuth.setupEnvironment();
      user = graphQLAuth.getUserMap();
    }
    return await Future.sync(() => user);
  }

  @override
  void initState() {
    super.initState();
    proxyStartedSubscription = eventBus.on<ProxyStarted>().listen((event) {
      setState(() {});
    });
    proxyEndedSubscription = eventBus.on<ProxyEnded>().listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    emailFormFieldController.dispose();
    nameFormFieldController.dispose();
    homeFormFieldController.dispose();
    proxyStartedSubscription.cancel();
    proxyEndedSubscription.cancel();
    super.dispose();
  }

  bool _formReady() {
    if (shouldCreateUser) {
      if ((_isWeb && _webImage != null || !_isWeb && _image != null) &&
          nameIsValid &&
          homeIsValid) {
        return true;
      }
    } else {
      if ((_isWeb && _webImage != null || !_isWeb && _image != null) ||
          (nameIsValid && homeIsValid)) {
        return true;
      }
    }
    return false;
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
                          setState(() {
                            _uploadInProgress = true;
                          });
                          await doUploads(context);
                          setState(() {
                            formReady = false;
                            _uploadInProgress = false;
                          });
                        })
            ],
          );
  }

  Future<void> doUploads(BuildContext context) async {
    try {
      if (imageUpdated) {
        MultipartFile multipartFile;
        if (_isWeb && _webImage != null) {
          multipartFile = MultipartFile.fromBytes('image', _webImage,
              filename: '$userId.jpg', contentType: MediaType('image', 'jpeg'));
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
      if (!nameIsValid || !homeIsValid) {
        return;
      }
      final QueryResult queryResult = await createOrUpdateUserInfo(
        shouldCreateUser,
        graphQLClient,
        jpegPathUrl: jpegPathUrl == null ? userImage : jpegPathUrl,
        id: userId,
        email: emailFormFieldController.text,
        name: nameFormFieldController.text,
        home: homeFormFieldController.text,
        isBook: isBook,
        bookAuthorEmail: graphQLAuth.getOriginalUserMap()['email'],
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

      if (isBook) {
        //make friends
        await addUserFriend(
          graphQLClient,
          userId,
          graphQLAuth.getOriginalUserMap()['id'],
        );

        await addUserFriend(
          graphQLClient,
          graphQLAuth.getOriginalUserMap()['id'],
          userId,
        );
      }
      shouldCreateUser = false;

      //This enables the other tabs
      eventBus.fire(ProfileEvent(true));

      //Friends page can refetch
      if (isBook) {
        eventBus.fire(BookWasAdded());
      }

      Fluttertoast.showToast(
          msg: Strings.saved.i18n,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      print(e.toString());
      logger.createMessage(
          userEmail: graphQLAuth.getUser().email,
          source: 'profile_page',
          shortMessage: e.exception.toString(),
          stackTrace: StackTrace.current.toString());
      rethrow;
    }
    return;
  }

  Widget getForm() {
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
        if (_isWeb) {
          _width = _height = 250;
        } else {
          _width = _height = 100;
        }
    }

    return SingleChildScrollView(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(10),
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
              else if (_webImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: Image.memory(
                    _webImage,
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
                height: 15,
              ),
              Text(
                Strings.yourPictureSelection.i18n,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(
                height: 15,
              ),
              ImageControls(
                  showIcons: true,
                  isWeb: _isWeb,
                  onOpenFileExplorer: (bool opening) {
                    setState(() {
                      _uploadInProgress = opening;
                    });
                  },
                  onWebCroppedCallback: (ByteData imageBytes) async {
                    setState(() {
                      _webImage = imageBytes.buffer.asUint8List(
                          imageBytes.offsetInBytes, imageBytes.lengthInBytes);

                      _uploadInProgress = true;
                      imageUpdated = true;
                    });
                    await doUploads(context);
                    setState(() {
                      _uploadInProgress = false;
                    });
                  },
                  onImageSelected: (io.File croppedFile) async {
                    setState(() {
                      _image = croppedFile;
                      _uploadInProgress = true;
                      imageUpdated = true;
                    });

                    await doUploads(context);

                    setState(() {
                      _uploadInProgress = false;
                      _formReady();
                    });
                  }),
              SizedBox(
                height: 15,
              ),
              isBook
                  ? Container()
                  : Container(
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
                          labelText: isBook ? 'Id' : Strings.emailLabel.i18n,
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
                  key: _nameFormKey,
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
                  onChanged: (value) {
                    setState(() {
                      if (_nameFormKey.currentState.validate()) {
                        formReady = _formReady();
                      }
                    });
                  },
                  validator: (value) {
                    nameIsValid = false;
                    if (value.isEmpty) {
                      return Strings.nameEmptyMessage.i18n;
                    }
                    if (value.length < 5) {
                      return Strings.nameLengthMessage.i18n;
                    }
                    nameIsValid = true;
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
                  key: _homeFormKey,
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
                  onChanged: (value) {
                    setState(() {
                      if (_homeFormKey.currentState.validate()) {
                        formReady = _formReady();
                      }
                    });
                  },
                  validator: (value) {
                    homeIsValid = false;
                    if (value.isEmpty) {
                      return Strings.homeEmptyMessage.i18n;
                    }
                    if (!(value.length > 1)) {
                      return 'Home length must be greater than 1';
                    }
                    homeIsValid = true;
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
        ));
  }

  Widget _progressIndicator() {
    return SizedBox(
      width: 200.0,
      height: 300.0,
      child: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isWeb = AppConfig.of(context).isWeb;
    graphQLAuth = locator<GraphQLAuth>();
    graphQLClientFileServer =
        graphQLAuth.getGraphQLClient(GraphQLClientType.FileServer);
    graphQLClient = GraphQLProvider.of(context).value;

    return FutureBuilder(
        future: Future.wait([getUser()]),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logger.createMessage(
                userEmail: graphQLAuth.getUser().email,
                source: 'profile_page',
                shortMessage: snapshot.error.toString(),
                stackTrace: StackTrace.current.toString());

            return Text('\nErrors: \n  ' + snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return _progressIndicator();
          }
          user = snapshot.data[0];
          isBook = user['isBook'] || widget.isBook;

          //if user is new, user['id'] will be empty
          if (user['id'].isNotEmpty && userId != user['id']) {
            userId = user['id'];
            userImage = user['image'];
            emailFormFieldController.text = user['email'];
            nameFormFieldController.text = user['name'];
            homeFormFieldController.text = user['home'];
            nameIsValid = true;
            homeIsValid = true;
          }
          if (userId == null || userId.isEmpty) {
            userId = Uuid().v1();
            if (isBook) {
              emailFormFieldController.text = userId;
            }
            shouldCreateUser = true;
          }
          return Scaffold(
            key: _scaffoldKey,
            drawer: isBook ? null : getDrawer(context),
            appBar: AppBar(
                title: Text(Strings.MFV.i18n),
                backgroundColor: Constants.backgroundColor,
                actions: checkProxy(
                  graphQLAuth,
                  context,
                )),
            body: getForm(),
          );
        });
  }
}
