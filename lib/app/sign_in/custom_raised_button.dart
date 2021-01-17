import 'package:flutter/material.dart';

@immutable
class CustomRaisedButton extends StatelessWidget {
  const CustomRaisedButton({
    Key key,
    @required this.text,
    this.loading = false,
    this.onPressed,
    this.icon,
    this.fontSize = 20,
  }) : super(key: key);

  final String text;
  final bool loading;
  final VoidCallback onPressed;
  final Icon icon;
  final double fontSize;

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
    return Padding(
      padding: EdgeInsets.fromLTRB(5, 5, 10, 5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      onPrimary: Colors.black87,
      primary: Color(0xff00bcd4),
      minimumSize: Size(88, 36),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
    );

    return loading == true
        ? buildSpinner(context)
        : icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton.icon(
                    style: raisedButtonStyle,
                    onPressed: onPressed,
                    icon: icon,
                    label: buildText(
                      text,
                      context,
                    ),
                  )
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: raisedButtonStyle,
                    onPressed: onPressed,
                    child: loading
                        ? buildSpinner(context)
                        : buildText(
                            text,
                            context,
                          ),
                  )
                ],
              );
  }
}
