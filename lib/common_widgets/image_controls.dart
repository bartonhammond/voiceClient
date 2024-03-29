import 'dart:io' as io;
import 'dart:typed_data';
import 'package:MyFamilyVoice/app_config.dart';
import 'package:MyFamilyVoice/common_widgets/image_editor/image_editor.dart';
import 'package:MyFamilyVoice/services/auth_service_adapter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Function(ByteData) onImageSelected;
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
      await Navigator.of(context, rootNavigator: true).push<dynamic>(
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) {
            return ImageEditor(
              bytes: _paths[0].bytes,
              onImageSelected: widget.onImageSelected,
            );
          },
          fullscreenDialog: true,
        ),
      );
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
      final Uint8List bytes = file.readAsBytesSync();
      return widget.onImageSelected(ByteData.view(bytes.buffer));
    }

    final PickedFile pickedFile = await picker.getImage(source: source);
    if (pickedFile != null) {
      image = io.File(pickedFile.path);
    }

    if (image != null && pickedFile != null) {
      await Navigator.of(context, rootNavigator: true).push<dynamic>(
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) {
            return ImageEditor(
              bytes: image.readAsBytesSync(),
              onImageSelected: widget.onImageSelected,
            );
          },
          fullscreenDialog: true,
        ),
      );
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
