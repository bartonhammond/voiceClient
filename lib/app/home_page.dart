import 'dart:async';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

const String uploadImage = r'''
mutation($file: Upload!) {
  upload(file: $file)
}
''';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File _image;
  bool _uploadInProgress = false;
  final picker = ImagePicker();
  var uuid = Uuid();

  Future selectImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barton'),
      ),
      body: _buildPage(),
    );
  }

  Widget _buildPage() {
    return Column(
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
            flex: 9,
            child: Center(
              child: Text('No Image Selected'),
            ),
          ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              FlatButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.photo_library),
                    SizedBox(
                      width: 5,
                    ),
                    Text('Select File'),
                  ],
                ),
                onPressed: () => selectImage(),
              ),
              if (_image != null)
                Mutation(
                  options: MutationOptions(
                      documentNode: gql(uploadImage),
                      onCompleted: (dynamic d) {
                        print(d);
                        setState(() {
                          _uploadInProgress = false;
                        });
                      },
                      update: (cache, results) {
                        final message = results.hasException
                            ? '${results.exception}'
                            : 'Image was uploaded successfully!';
                        //final snackBar = SnackBar(content: Text(message));
                        //Scaffold.of(context).showSnackBar(snackBar);
                      }),
                  builder: (
                    RunMutation runMutation,
                    QueryResult result,
                  ) {
                    return FlatButton(
                      child: _isLoadingInProgress(),
                      onPressed: () {
                        setState(() {
                          _uploadInProgress = true;
                        });

                        final byteData = _image.readAsBytesSync();

                        final multipartFile = MultipartFile.fromBytes(
                          'photo',
                          byteData,
                          filename: '${uuid.v1()}.jpg',
                          contentType: MediaType('image', 'jpg'),
                        );

                        runMutation(<String, dynamic>{
                          'file': multipartFile,
                        });
                      },
                    );
                  },
                ),
            ],
          ),
        )
      ],
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
              Text('Upload File'),
            ],
          );
  }
}
