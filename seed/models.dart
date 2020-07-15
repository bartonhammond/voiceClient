class AudioOutputBase64Encoded {
  AudioOutputBase64Encoded({this.audioContent});
  AudioOutputBase64Encoded.fromJson(Map<String, dynamic> json) {
    audioContent = json['audioContent'];
  }
  String audioContent;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'audioContent': audioContent,
      };
}
