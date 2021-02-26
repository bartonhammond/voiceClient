import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/ql/story/story_search.dart';
import 'package:MyFamilyVoice/ql/story_ql.dart';
import 'package:MyFamilyVoice/services/eventBus.dart';
import 'package:MyFamilyVoice/services/host.dart';
import 'package:MyFamilyVoice/services/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({
    Key key,
  }) : super(key: key);

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

  List<dynamic> _stories;
  final List<_TaskInfo> _tasks = [];

  final ReceivePort _port = ReceivePort();
  int _storiesDownloaded = 0;
  String _localPath;
  bool _permissionReady;
  TargetPlatform _platform;
  bool _loading = false;
  bool _downloadComplete = false;
  bool _downloading = false;
  Directory _savedDir;
  StreamSubscription taskCompletedSubscription;
  @override
  void initState() {
    _permissionReady = false;
    Future.delayed(const Duration(milliseconds: 1), () async {
      _stories = null;
      _downloadComplete = false;
      _downloading = false;
      _storiesDownloaded = 0;
      _tasks.clear();

      try {
        await FlutterDownloader.initialize(debug: false);
      } catch (e) {
        //ignore initialization error
      }
      FlutterDownloader.registerCallback(downloadCallback);
      _bindBackgroundIsolate();

      _checkPermission().then((hasGranted) {
        setState(() {
          _permissionReady = hasGranted;
        });
      });
    });
    //Run one task at a time
    //Sleep between
    taskCompletedSubscription =
        eventBus.on<TaskCompleted>().listen((event) async {
      //queue everything
      //copy to avoid concurrent modification
      for (var task in List<_TaskInfo>.from(_tasks)) {
        if (task.taskId == null) {
          Future.delayed(const Duration(milliseconds: 500), () async {
            await _requestDownload(task);
          });
          break;
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    taskCompletedSubscription.cancel();
    super.dispose();
  }

  Widget getDownloadButton() {
    return CustomRaisedButton(
        key: Key('downloadPageDownload'),
        text: Strings.upload.i18n,
        icon: Icon(
          Icons.save,
          color: Colors.white,
        ),
        onPressed: _downloadComplete || _downloading
            ? null
            : () async {
                _loading = true;
                _localPath = (await _findLocalPath()) +
                    Platform.pathSeparator +
                    'Download';

                _savedDir = Directory(_localPath);
                final bool hasExisted = _savedDir.existsSync();
                if (!hasExisted) {
                  _savedDir.create();
                }
                final File _jsonfile =
                    await File(join(_savedDir.path, 'stories.txt')).create();
                String _storiesString = "{'stories': [";
                for (var story in _stories) {
                  _storiesString += toJson(story);
                }
                _storiesString += ']}';
                await _jsonfile.writeAsString(_storiesString);
                await clearTasksSql();
                _loading = false;
                //initiate the downloads
                _downloading = true;
                eventBus.fire(TaskCompleted());
              });
  }

  void _bindBackgroundIsolate() {
    final bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      final String id = data[0];
      final DownloadTaskStatus status = data[1];

      if (_tasks != null && _tasks.isNotEmpty) {
        final task = _tasks.firstWhere((task) => task.taskId == id, orElse: () {
          return null;
        });
        if (task != null) {
          setState(() {
            if (status == DownloadTaskStatus.complete) {
              _storiesDownloaded++;
              eventBus.fire(TaskCompleted());
            }
            _downloadComplete = false;
            if (_tasks.length == _storiesDownloaded) {
              _downloadComplete = true;
              _downloading = false;
            }
          });
        }
      }
    });
  }

  Widget getShowFileButton() {
    return CustomRaisedButton(
      key: Key('download'),
      text: Strings.downloadsViewSummaryFile.i18n,
      icon: Icon(
        Icons.folder_open,
        color: Colors.white,
      ),
      onPressed: () async {
        await OpenFile.open(join(_savedDir.path, 'stories.txt'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _platform = Theme.of(context).platform;
    return FutureBuilder(
      future: Future.wait([
        getStories(context, _stories),
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          logger.createMessage(
              userEmail: graphQLAuth.getUser().email,
              source: 'downloadPage',
              shortMessage: snapshot.error.toString(),
              stackTrace: StackTrace.current.toString());
          return Text('\nErrors: \n  ' + snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return Scaffold(
            key: _scaffoldKey,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (_stories == null) {
          _stories = snapshot.data[0];
          if (_stories != null) {
            for (var story in _stories) {
              _tasks.add(_TaskInfo(
                  link: host(
                story['image'],
                width: 200,
                height: 200,
                resizingType: 'fill',
                enlarge: 1,
              )));
              _tasks.add(_TaskInfo(
                  link: host(
                story['audio'],
              )));
            }
          }
        }

        return WillPopScope(
            onWillPop: () async {
              if (_storiesDownloaded > 0 && !_downloadComplete) {
                final bool saveChanges = await PlatformAlertDialog(
                        title: Strings.downloadsDownloadingInProgress,
                        content: Strings.downloadsStayToFinishDownloading.i18n,
                        cancelActionText: Strings.no.i18n,
                        defaultActionText: Strings.yes.i18n)
                    .show(context);
                if (saveChanges == true) {
                  return false;
                }
                return true;
              }
              return true;
            },
            child: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                backgroundColor: Color(0xff00bcd4),
                title: Text(Strings.MFV.i18n),
              ),
              body: Container(
                width: 500,
                child: _permissionReady && _stories != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                            getDownloadButton(),
                            Text(
                                '${Strings.downloadsNumberOfStories.i18n}: ${_stories.length}'),
                            _loading
                                ? CircularProgressIndicator()
                                : Container(),
                            Container(
                                padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                                child: LinearProgressIndicator(
                                  value: _storiesDownloaded /
                                      (_stories.length * 2),
                                )),
                            _downloadComplete
                                ? RichText(
                                    text: TextSpan(
                                    text:
                                        '${Strings.downloadsFilesLocatedHere.i18n}: ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: _platform ==
                                                TargetPlatform.android
                                            ? 'internal storage/Android/data/online.myfamilyvoice.mobile/files/Download'
                                            : 'On My [iPhone/iPad]/My Family Voice/Download/',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ))
                                : Container(),
                            _downloadComplete
                                ? getShowFileButton()
                                : Container()
                          ])
                    : _buildNoPermissionWarning(),
              ),
            ));
      },
    );
  }

  Future<List<dynamic>> getStories(BuildContext context, List _stories) {
    if (_stories != null) {
      return Future.value(_stories);
    }
    StoryQl storyQl;
    storyQl = StoryQl();
    final StorySearch storySearch = StorySearch.init(
      GraphQLProvider.of(context).value,
      storyQl,
      graphQLAuth.getUser().email,
    );
    final DateTime now = DateTime.now();
    final _values = <String, dynamic>{
      'currentUserEmail': graphQLAuth.getUser().email,
      'limit': 100000.toString(),
      'cursor': now.toIso8601String(),
    };
    storySearch.setQueryName('userStoriesMe');
    return storySearch.getList(_values);
  }

  Future<String> _findLocalPath() async {
    Directory directory;
    if (_platform == TargetPlatform.android) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    return directory.path;
  }

  Future<void> clearTasksSql() async {
    //clear sql
    final tasks = await FlutterDownloader.loadTasks();
    for (var task in tasks) {
      await FlutterDownloader.remove(taskId: task.taskId);
    }
  }

  Future<void> _requestDownload(_TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link,
        savedDir: _localPath,
        showNotification: false,
        openFileFromNotification: false);
  }

  Future<bool> _checkPermission() async {
    if (_platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Widget _buildNoPermissionWarning() => Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  Strings.downloadsPleaseGrantStoragePermission.i18n,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 18.0),
                ),
              ),
              SizedBox(
                height: 32.0,
              ),
              FlatButton(
                  onPressed: () {
                    _checkPermission().then((hasGranted) {
                      setState(() {
                        _permissionReady = hasGranted;
                      });
                    });
                  },
                  child: Text(
                    Strings.downloadsRetry.i18n,
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ))
            ],
          ),
        ),
      );

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }
}

class _TaskInfo {
  _TaskInfo({this.link});
  final String link;
  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;
}
