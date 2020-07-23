import 'package:voiceClient/app/sign_in/custom_raised_button.dart';
import 'package:flutter/material.dart';

class FormSubmitButton extends CustomRaisedButton {
  const FormSubmitButton({
    Key key,
    String text,
    bool loading = false,
    VoidCallback onPressed,
  }) : super(
          key: key,
          text: text,
          loading: loading,
          onPressed: onPressed,
        );
}
