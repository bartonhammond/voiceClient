import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:voiceClient/constants/transparent_image.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({
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
  String title = '';
  String description = '';
  io.File _image;
  String imageFilePath;
  final picker = ImagePicker();
  bool _uploadInProgress = false;

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
        //await doUploads(context);
        setState(() {
          _image = null;
          _uploadInProgress = false;
        });
        //pop back to tab for stories
        //widget.onFinish(true);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: NeumorphicTheme.currentTheme(context).variantColor,
      ),
      body: Form(
        key: _formKey,
        child: Column(
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
                    Positioned(
                      left: (MediaQuery.of(context).size.width / 2) - 50,
                      top: 35,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                        child: Image.asset(
                          'assets/user.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.fill,
                        ),
                      ),
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
                        'Your Profile Image Placeholder',
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
              'Image Selection',
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
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  filled: true,
                  hintText: 'Enter your full name...',
                  labelText: 'Name',
                ),
                onChanged: (value) {
                  setState(() {
                    title = value;
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
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  filled: true,
                  hintText: 'Enter your city, state',
                  labelText: 'Home',
                ),
                onChanged: (value) {
                  description = value;
                },
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              margin: const EdgeInsets.only(right: 10, left: 10),
              child: TextFormField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  filled: true,
                  hintText: 'Birth year',
                  labelText: 'Year of your birth',
                ),
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
              ),
            ),
            SizedBox(
              height: 45,
            ),
          ],
        ),
      ),
    );
  }
}
