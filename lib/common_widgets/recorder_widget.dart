import 'dart:async';
import 'dart:io' as io;

import 'package:MyFamilyVoice/app_config.dart';
import 'package:MyFamilyVoice/services/auth_service_adapter.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_timer/simple_timer.dart';
import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:MyFamilyVoice/common_widgets/player_widget.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RecorderWidget extends StatefulWidget {
  RecorderWidget({
    Key key,
    this.isCurrentUserAuthor = false,
    this.isForComment = false,
    this.setAudioFile,
    this.timerDuration = 180,
    this.showIcon = true,
    this.width = 200,
    this.url = '',
    this.showStacked = false,
    this.showPlayerWidget = true,
  }) : super(key: key);
  final ValueChanged<io.File> setAudioFile;
  final bool isCurrentUserAuthor;
  final bool isForComment;
  final int timerDuration;
  final bool showIcon;
  final int width;
  final String url;
  final bool showStacked;
  final bool showPlayerWidget;

  final LocalFileSystem localFileSystem = LocalFileSystem();
  @override
  State<StatefulWidget> createState() => _RecorderWidgetState();
}

class _RecorderWidgetState extends State<RecorderWidget>
    with SingleTickerProviderStateMixin {
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  //If AuthServiceType.mock, the animation doesnt
  TimerController _timerController;
  final TimerStyle _timerStyle = TimerStyle.ring;
  final TimerProgressIndicatorDirection _progressIndicatorDirection =
      TimerProgressIndicatorDirection.counter_clockwise;
  final TimerProgressTextCountDirection _progressTextCountDirection =
      TimerProgressTextCountDirection.count_down;

  bool _stopButtonEnabled = true;
  String _localAudioPath;
  AuthServiceType _authServiceType;
  FToast _fToast;
  @override
  void initState() {
    super.initState();
    _timerController = TimerController(this);
    _stopButtonEnabled = false;
    _localAudioPath = '';
    if (!kIsWeb) {
      _init();
    }
    _fToast = FToast();
    _fToast.init(context);
  }

  Widget getRecordButton(bool _showIcon) {
    final dynamic textAndIcon = _buildText(_currentStatus);
    return CustomRaisedButton(
      key: Key('recorderWidgetRecordButton'),
      text: textAndIcon['text'],
      icon: _showIcon
          ? Icon(
              textAndIcon['icon'],
              color: Colors.white,
            )
          : null,
      onPressed: () {
        switch (_currentStatus) {
          case RecordingStatus.Initialized:
            {
              _start();
              break;
            }
          case RecordingStatus.Recording:
            {
              _pause();
              break;
            }
          case RecordingStatus.Paused:
            {
              _resume();
              break;
            }
          case RecordingStatus.Stopped:
            {
              _init();
              break;
            }
          default:
            break;
        }
      },
    );
  }

  Future<void> _init() async {
    try {
      if (kIsWeb) {
        return;
      }
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        io.Directory appDocDirectory;
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }
        // can add extension like ".mp3" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString() +
            '.mp3';

        // .wav <---> AudioFormat.WAV
        // .mp3 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.AAC);

        await _recorder.initialized;
        // after initialization
        final current = await _recorder.current(channel: 0);
        // should be "Initialized", if all working fine
        setState(() {
          if (_authServiceType != AuthServiceType.mock) {
            _timerController.reset();
          }
          _current = current;
          _currentStatus = current.status;
          widget.setAudioFile(null);
          _stopButtonEnabled = false;
          _localAudioPath = '';
        });
      } else {
        _showToast(Strings.mustAcceptPermissions.i18n);
      }
    } catch (e) {
      print(e);
    }
    return;
  }

  void _showToast(String message) {
    final Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.black,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text(message,
              key: Key('recorderWidgetToast'),
              style: TextStyle(
                  backgroundColor: Colors.black,
                  color: Colors.white,
                  fontSize: 16.0))
        ],
      ),
    );

    _fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 3),
    );
  }

  Future<void> _start() async {
    try {
      await _recorder.start();
      final recording = await _recorder.current(channel: 0);
      setState(() {
        if (_authServiceType != AuthServiceType.mock) {
          _timerController.start();
        }
        _current = recording;
        _stopButtonEnabled = true;
      });
      const tick = Duration(milliseconds: 50);
      Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        final current = await _recorder.current(channel: 0);
        setState(() {
          _current = current;
          _currentStatus = _current.status;
        });
      });
    } catch (e) {
      print(e);
    }
    return;
  }

  Future<void> _resume() async {
    await _recorder.resume();
    setState(() {
      if (_authServiceType != AuthServiceType.mock) {
        _timerController.start();
      }
      _stopButtonEnabled = true;
    });
    return;
  }

  Future<void> _pause() async {
    await _recorder.pause();
    setState(() {
      if (_authServiceType != AuthServiceType.mock) {
        _timerController.pause();
      }
      _stopButtonEnabled = false;
    });
    return;
  }

  Future<void> _stop() async {
    final result = await _recorder.stop();
    widget.setAudioFile(widget.localFileSystem.file(result.path));
    setState(() {
      _current = result;
      _currentStatus = _current.status;
      _localAudioPath = _current.path;
      if (_authServiceType != AuthServiceType.mock) {
        _timerController.pause();
      }
      _stopButtonEnabled = false;
    });
  }

  dynamic _buildText(RecordingStatus status) {
    var text = '';
    IconData iconData;
    switch (_currentStatus) {
      case RecordingStatus.Initialized:
        {
          text = Strings.audioRecord.i18n;
          iconData = Icons.mic;
          break;
        }
      case RecordingStatus.Recording:
        {
          text = Strings.audioPause.i18n;
          iconData = Icons.pause_circle_outline;
          break;
        }
      case RecordingStatus.Paused:
        {
          text = Strings.audioResume.i18n;
          iconData = Icons.mic_off;
          break;
        }
      case RecordingStatus.Stopped:
        {
          text = Strings.audioClear.i18n;
          iconData = Icons.clear;
          break;
        }
      default:
        break;
    }
    return {'icon': iconData, 'text': text};
  }

  Future<void> handleTimerOnEnd() async {
    await _stop();
  }

  Widget getCountdownTimer() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: SimpleTimer(
        duration: Duration(seconds: widget.timerDuration),
        controller: _timerController,
        timerStyle: _timerStyle,
        backgroundColor: Color(0xff00bcd4),
        onEnd: handleTimerOnEnd,
        progressIndicatorColor: Colors.red,
        progressIndicatorDirection: _progressIndicatorDirection,
        progressTextCountDirection: _progressTextCountDirection,
        progressTextStyle: TextStyle(color: Colors.black),
        strokeWidth: 5,
      ),
    );
  }

  Widget getRecordWidget() {
    if (widget.isCurrentUserAuthor || widget.isForComment) {
      double level = _current?.metering?.averagePower;
      if (level != null) {
        level += 120;
      } else {
        level = 0;
      }
      if (_currentStatus == RecordingStatus.Stopped) {
        level = 0;
      }
      return widget.showStacked
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: getChildren(level))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: getChildren(level));
    }
    return Container();
  }

  Widget getPlayerWidget() {
    if (_localAudioPath != null && _localAudioPath.isNotEmpty) {
      return PlayerWidget(
        width: widget.width,
        path: _localAudioPath,
        isLocal: true,
        url: '',
        resetPosition: true,
      );
    }
    if (widget.url != null && widget.url.isNotEmpty) {
      return PlayerWidget(
        width: widget.width,
        path: '',
        isLocal: false,
        url: widget.url,
        resetPosition: true,
      );
    }
    return Container();
  }

  List<Widget> getChildren(double level) {
    return <Widget>[
      getRecordButton(widget.showIcon),
      SizedBox(
        width: 4,
      ),
      CustomRaisedButton(
        key: Key('recorderWidgetStopButton'),
        text: Strings.audioStop.i18n,
        icon: widget.showIcon
            ? Icon(
                Icons.stop,
                color: Colors.white,
              )
            : null,
        onPressed: _stopButtonEnabled ? _stop : null,
      ),
      SizedBox(
        width: 4,
      ),
      Container(
        height: 40,
        child: _authServiceType == AuthServiceType.mock
            ? Container()
            : Container(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: FAProgressBar(
                  currentValue: level.toInt(),
                  maxValue: 100,
                  size: 15,
                  animatedDuration: const Duration(milliseconds: 400),
                  direction: Axis.vertical,
                  verticalDirection: VerticalDirection.up,
                  borderRadius: 8,
                  border: Border.all(
                    color: level == 0.0 ? Colors.transparent : Colors.indigo,
                    width: 0.5,
                  ),
                  backgroundColor:
                      level == 0.0 ? Colors.transparent : Colors.white,
                  progressColor: level == 0.0 ? Colors.transparent : Colors.red,
                  changeColorValue: 75,
                  changeProgressColor:
                      level == 0.0 ? Colors.transparent : Colors.green,
                ),
              ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    _authServiceType = AppConfig.of(context).authServiceType;
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                Strings.currentAudio.i18n,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          widget.showPlayerWidget
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    getPlayerWidget(),
                  ],
                )
              : Container(),
          getRecordWidget(),
          widget.isCurrentUserAuthor || widget.isForComment
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                      SizedBox(
                        height: 8,
                      ),
                      getCountdownTimer(),
                    ])
              : Container(),
        ],
      ),
    );
  }
}
