import 'package:voiceClient/services/logger.dart' as logger;

Future<void> main(List<String> arguments) async {
  try {
    throw Exception('stupid');
  } catch (e) {
    await logger.createMessage(
        shortMessage: e.toString(),
        userEmail: 'bartonhammond@gmail.com',
        source: 'testGelf',
        stackTrace: StackTrace.current.toString());
  }
}
