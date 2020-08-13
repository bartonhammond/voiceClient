import 'dart:async';
import 'dart:io' as io;

import 'package:audioplayers/audioplayers.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_timer/simple_timer.dart';

import 'package:voiceClient/app/sign_in/custom_raised_button.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';
import 'package:voiceClient/constants/strings.dart';

class RecorderWidget extends StatefulWidget {
  RecorderWidget({
    Key key,
    this.id,
    this.setAudioFile,
    this.timerDuration = 180,
  }) : super(key: key);
  final String id;
  final ValueChanged<io.File> setAudioFile;

  final int timerDuration;

  final LocalFileSystem localFileSystem = LocalFileSystem();
  @override
  State<StatefulWidget> createState() => _RecorderWidgetState();
}

class _RecorderWidgetState extends State<RecorderWidget>
    with SingleTickerProviderStateMixin {
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  TimerController _timerController;
  final TimerStyle _timerStyle = TimerStyle.ring;
  final TimerProgressIndicatorDirection _progressIndicatorDirection =
      TimerProgressIndicatorDirection.counter_clockwise;
  final TimerProgressTextCountDirection _progressTextCountDirection =
      TimerProgressTextCountDirection.count_down;

  @override
  void initState() {
    super.initState();
    _timerController = TimerController(this);
    _init();
  }

  Future<void> onPlayAudio() async {
    final AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(_current.path, isLocal: true);
    return;
  }

  Widget getRecordButton() {
    final dynamic textAndIcon = _buildText(_currentStatus);
    return CustomRaisedButton(
      key: Key(Keys.storyPageGalleryButton),
      text: textAndIcon['text'],
      icon: Icon(
        textAndIcon['icon'],
        color: Colors.white,
      ),
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
          _timerController.reset();
          _current = current;
          _currentStatus = current.status;
        });
      } else {
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(Strings.mustAcceptPermissions.i18n)));
      }
    } catch (e) {
      print(e);
    }
    return;
  }

  Future<void> _start() async {
    try {
      await _recorder.start();
      final recording = await _recorder.current(channel: 0);
      setState(() {
        _timerController.start();
        _current = recording;
      });

      const tick = Duration(milliseconds: 50);
      Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        final current = await _recorder.current(channel: 0);
        // print(current.status);
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
      _timerController.start();
    });
    return;
  }

  Future<void> _pause() async {
    await _recorder.pause();
    setState(() {
      _timerController.pause();
    });
    return;
  }

  Future<void> _stop() async {
    final result = await _recorder.stop();
    widget.setAudioFile(widget.localFileSystem.file(result.path));
    setState(() {
      _current = result;
      _currentStatus = _current.status;
      _timerController.pause();
    });
    return;
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

  void handleTimerOnEnd() {
    _stop();
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

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              getRecordButton(),
              SizedBox(
                width: 4,
              ),
              CustomRaisedButton(
                key: Key(Keys.storyPageStopButton),
                text: Strings.audioStop.i18n,
                icon: Icon(
                  Icons.stop,
                  color: Colors.white,
                ),
                onPressed:
                    _currentStatus != RecordingStatus.Unset ? _stop : null,
              ),
              SizedBox(
                width: 4,
              ),
              CustomRaisedButton(
                key: Key(Keys.storyPagePlayButton),
                text: Strings.audioPlay.i18n,
                icon: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                ),
                onPressed: onPlayAudio,
              ),
            ],
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(
                  height: 8,
                ),
                getCountdownTimer(),
              ]),
        ],
      ),
    );
  }
}