import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'constants.dart';
import 'models.dart';

Future<void> textToSpeech(
  String text,
  String audioFileName,
  String languageCode,
  String voice,
) async {
  try {
    //query google voice api and get response which is base 64 encoded.
    final apiResult = await _getAudioBase64Output(
      languageCode,
      voice,
      text,
    );
    //decode base64 file and save as binary audio file (mp3)
    final dynamic bytes = base64.decode(apiResult.audioContent);
    final fileType = AUDIO_ENCODING.toLowerCase();

    final file = File('$audioFileName.$fileType');

    await file.writeAsBytes(bytes.buffer.asUint8List());
    return;
  } catch (e) {
    //output error
    stderr.writeln('error: networking error');
    stderr.writeln(e.toString());
    rethrow;
  }
}

Future<AudioOutputBase64Encoded> _getAudioBase64Output(
  String languageCode,
  String voiceName,
  String text,
) async {
  //create api URL from global constants
  const _apiURL = '$BASE_URL$END_POINT?key=$API_KEY';

  //create json body from global constants and input variables
  final body =
      '{"input": {"text":"$text"},"voice": {"languageCode": "$languageCode", "name": "$voiceName"},"audioConfig": {"audioEncoding": "$AUDIO_ENCODING"}}';

  print('textToSpeech.body: $body');
  //send post request to google text to speech api
  final Future request = http.post(_apiURL, body: body);
  //get response
  final dynamic response = await _getResponse(request);
  //return our mapped response from our AudioOutputBase64Encoded model
  return AudioOutputBase64Encoded.fromJson(response);
}

Future _getResponse(Future<http.Response> request) {
  //return our response if good (200 code) or throw error if failed
  return request.then<dynamic>((response) {
    //print(response.statusCode);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw jsonDecode(response.body);
  });
}
