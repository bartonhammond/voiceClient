import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:flutter/services.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;
import 'package:MyFamilyVoice/services/service_locator.dart';

class PlatformExceptionAlertDialog extends PlatformAlertDialog {
  PlatformExceptionAlertDialog({String title, PlatformException exception})
      : super(
          title: title,
          content: message(exception),
          defaultActionText: 'OK',
        );

  static String message(PlatformException exception) {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    if (exception.message == 'FIRFirestoreErrorDomain') {
      if (exception.code == 'Code 7') {
        // This happens when we get a "Missing or insufficient permissions" error
        logger.createMessage(
            userEmail: graphQLAuth.getUser().email,
            source: 'platform_exception_alert_dialog',
            shortMessage:
                'This operation could not be completed due to a server error',
            stackTrace: StackTrace.current.toString());
        return 'This operation could not be completed due to a server error';
      }
      logger.createMessage(
          userEmail: graphQLAuth.getUser().email,
          source: 'platform_exception_alert_dialog',
          shortMessage: exception.message,
          stackTrace: StackTrace.current.toString());
      return exception.details;
    }
    logger.createMessage(
        userEmail: graphQLAuth.getUser().email,
        source: 'platform_exception_alert_dialog',
        shortMessage: errors[exception.code] ?? exception.message,
        stackTrace: StackTrace.current.toString());
    return errors[exception.code] ?? exception.message;
  }

  // NOTE: The full list of FirebaseAuth errors is stored here:
  // https://github.com/firebase/firebase-ios-sdk/blob/2e77efd786e4895d50c3788371ec15980c729053/Firebase/Auth/Source/FIRAuthErrorUtils.m
  // These are just the most relevant for email & password sign in:
  static Map<String, String> errors = {
    'ERROR_WEAK_PASSWORD': 'The password must be 8 characters long or more.',
    'ERROR_INVALID_CREDENTIAL': 'The email address is badly formatted.',
    'ERROR_EMAIL_ALREADY_IN_USE':
        'The email address is already registered. Sign in instead?',
    'ERROR_INVALID_EMAIL': 'The email address is badly formatted.',
    'ERROR_WRONG_PASSWORD': 'The password is incorrect. Please try again.',
    'ERROR_USER_NOT_FOUND':
        'The email address is not registered. Need an account?',
    'ERROR_TOO_MANY_REQUESTS':
        'We have blocked all requests from this device due to unusual activity. Try again later.',
    'ERROR_OPERATION_NOT_ALLOWED':
        'This sign in method is not allowed. Please contact support.',
  };
}
