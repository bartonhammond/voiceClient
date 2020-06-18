import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

@immutable
class CustomRaisedButton extends StatelessWidget {
  const CustomRaisedButton({
    Key key,
    @required this.text,
    this.loading = false,
    this.onPressed,
  }) : super(key: key);

  final String text;
  final bool loading;
  final VoidCallback onPressed;

  Widget buildSpinner(BuildContext context) {
    final ThemeData data = Theme.of(context);
    return Theme(
      data: data.copyWith(accentColor: Colors.white70),
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 3.0,
        ),
      ),
    );
  }

  Widget buildText(String text, BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: NeumorphicTheme.defaultTextColor(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: NeumorphicButton(
        child: loading
            ? buildSpinner(context)
            : buildText(
                text,
                context,
              ),
        onPressed: onPressed,
        margin: EdgeInsets.all(13),
        style: NeumorphicStyle(
          border: NeumorphicBorder(
            isEnabled: true,
            width: 1,
            color: Color.fromARGB(50, 235, 166, 166),
          ),
        ),
      ),
    );
  }
}
