class AudioOutputBase64Encoded {
  String audioContent;

  AudioOutputBase64Encoded({this.audioContent});

  AudioOutputBase64Encoded.fromJson(Map<String, dynamic> json) {
    audioContent = json['audioContent'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'audioContent': audioContent,
      };
}
