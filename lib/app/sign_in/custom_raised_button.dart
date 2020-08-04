import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

@immutable
class CustomRaisedButton extends StatelessWidget {
  const CustomRaisedButton({
    Key key,
    @required this.text,
    this.loading = false,
    this.onPressed,
    this.icon,
  }) : super(key: key);

  final String text;
  final bool loading;
  final VoidCallback onPressed;
  final Icon icon;

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
    return loading == true
        ? buildSpinner(context)
        : icon != null
            ? SizedBox(
                child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  color: NeumorphicTheme.currentTheme(context).variantColor,
                  onPressed: onPressed,
                  icon: icon,
                  padding: EdgeInsets.all(10),
                  label: buildText(
                    text,
                    context,
                  ),
                ),
              )
            : SizedBox(
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  color: NeumorphicTheme.currentTheme(context).variantColor,
                  onPressed: onPressed,
                  padding: EdgeInsets.all(5),
                  child: loading
                      ? buildSpinner(context)
                      : buildText(
                          text,
                          context,
                        ),
                ),
              );
  }
}
