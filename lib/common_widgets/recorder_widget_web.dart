import 'dart:typed_data';
import 'package:MyFamilyVoice/common_widgets/player_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:microphone/microphone.dart';
import 'package:simple_timer/simple_timer.dart';

enum AudioState { recording, play, stop, init }

const veryDarkBlue = Color(0xff172133);
const kindaDarkBlue = Color(0xff202641);

class RecorderWidgetWeb extends StatefulWidget {
  const RecorderWidgetWeb({
    Key key,
    this.isCurrentUserAuthor = false,
    this.isForComment = false,
    this.setAudioWeb,
    this.timerDuration = 180,
    this.showIcon = true,
    this.width = 200,
    this.url = '',
    this.showStacked = false,
    this.showPlayerWidget = true,
  }) : super(key: key);

  final ValueChanged<Uint8List> setAudioWeb;
  final bool isCurrentUserAuthor;
  final bool isForComment;
  final int timerDuration;
  final bool showIcon;
  final int width;
  final String url;
  final bool showStacked;
  final bool showPlayerWidget;

  @override
  _RecorderWidgetWebState createState() => _RecorderWidgetWebState();
}

class _RecorderWidgetWebState extends State<RecorderWidgetWeb>
    with SingleTickerProviderStateMixin {
  AudioState audioState;
  MicrophoneRecorder _recorder;
  String _recordingUrl;
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
    if (widget.isCurrentUserAuthor || widget.isForComment) {
      _recorder = MicrophoneRecorder()..init();
    }
  }

  @override
  void dispose() {
    if (_recorder != null) {
      _recorder.dispose();
    }
    super.dispose();
  }

  Future<void> handleAudioState(AudioState state) async {
    setState(() {
      if (audioState == null) {
        // Starts recording
        audioState = AudioState.recording;
      } else if (audioState == AudioState.recording) {
        audioState = AudioState.stop;
      }
    });

    if (audioState == AudioState.recording) {
      if (_recordingUrl != null && _recorder != null) {
        _recorder.dispose();
        _recorder = MicrophoneRecorder();
        await _recorder.init();
      }

      _recordingUrl = null;
      _recorder.start();
      _timerController.reset();
      _timerController.start();
    }
    if (audioState == AudioState.stop) {
      await _stop();
    }
  }

  Future<void> _stop() async {
    await _recorder.stop();
    setState(() {
      _timerController.pause();
      _recordingUrl = _recorder.value.recording.url;
      audioState = null;
    });

    final http.Response response = await http.get(_recordingUrl);
    widget.setAudioWeb(response.bodyBytes);
  }

  Widget getPlayerWidget() {
    if (_recordingUrl != null && _recordingUrl.isNotEmpty) {
      return PlayerWidget(
        width: widget.width,
        isLocal: false,
        url: _recordingUrl,
        resetPosition: true,
        showSlider: false,

        ///web not supported
      );
    }
    if (widget.url != null && widget.url.isNotEmpty) {
      return PlayerWidget(
        width: widget.width,
        path: '',
        isLocal: false,
        url: widget.url,
        resetPosition: true,
        showSlider: false,

        ///web not supported
      );
    }
    return Container();
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

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.showPlayerWidget
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    getPlayerWidget(),
                  ],
                )
              : Container(),
          widget.isCurrentUserAuthor || widget.isForComment
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: handleAudioColour(),
                      ),
                      child: RawMaterialButton(
                        fillColor: Colors.white,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(5),
                        onPressed: () => setState(() {
                          handleAudioState(audioState);
                        }),
                        child: getIcon(audioState),
                      ),
                    ),
                    SizedBox(width: 20),
                    getCountdownTimer(),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  Color handleAudioColour() {
    if (audioState == AudioState.recording) {
      return Colors.deepOrangeAccent.shade700.withOpacity(0.5);
    } else {
      return kindaDarkBlue;
    }
  }

  Icon getIcon(AudioState state) {
    if (state == AudioState.recording) {
      return Icon(Icons.mic, color: Colors.redAccent, size: 35);
    }

    return Icon(Icons.mic, size: 35);
  }
}
