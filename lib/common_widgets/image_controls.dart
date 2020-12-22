import 'dart:io' as io;

import 'package:MyFamilyVoice/app_config.dart';
import 'package:MyFamilyVoice/services/auth_service_adapter.dart';
import 'package:MyFamilyVoice/web/crop_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:MyFamilyVoice/constants/keys.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:path_provider/path_provider.dart';

class ImageControls extends StatefulWidget {
  const ImageControls({
    @required this.onImageSelected,
    @required this.onOpenFileExplorer,
    @required this.onWebCroppedCallback,
    this.showIcons = true,
    this.isWeb = false,
  });
  final Function(io.File) onImageSelected;
  final Function(bool) onOpenFileExplorer;
  final Function(ByteData) onWebCroppedCallback;
  final bool showIcons;
  final bool isWeb;

  @override
  _ImageControlsState createState() => _ImageControlsState();
}

class _ImageControlsState extends State<ImageControls> {
  final picker = ImagePicker();
  AuthServiceType _authServiceType;
//this is for web
  Future<void> _openFileExplorer() async {
    List<PlatformFile> _paths;

    widget.onOpenFileExplorer(true);

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
    widget.onOpenFileExplorer(false);

    if (!mounted) {
      return;
    }

    if (_paths != null) {
      Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => CropWidget(
              imageBytes: _paths[0].bytes,
              onCropped: widget.onWebCroppedCallback,
            ),
            fullscreenDialog: false,
          ));
    }
    return;
  }

  Future<io.File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = io.File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future selectImage(ImageSource source) async {
    io.File image;
    if (_authServiceType == AuthServiceType.mock) {
      final io.File file = await getImageFileFromAssets('me.jpg');
      return widget.onImageSelected(file);
    }

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
        widget.onImageSelected(croppedFile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _authServiceType = AppConfig.of(context).authServiceType;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        CustomRaisedButton(
          key: Key(Keys.storyPageGalleryButton),
          text: Strings.pictureGallery.i18n,
          icon: widget.showIcons
              ? Icon(
                  Icons.photo_library,
                  color: Colors.white,
                  size: 15.0,
                )
              : null,
          onPressed: () => widget.isWeb
              ? _openFileExplorer()
              : selectImage(ImageSource.gallery),
        ),
        SizedBox(
          width: 8,
        ),
        widget.isWeb
            ? Container()
            : CustomRaisedButton(
                key: Key(Keys.storyPageCameraButton),
                text: Strings.pictureCamera.i18n,
                icon: widget.showIcons
                    ? Icon(
                        Icons.camera,
                        color: Colors.white,
                        size: 15.0,
                      )
                    : null,
                onPressed: () => selectImage(ImageSource.camera),
              ),
      ],
    );
  }
}
