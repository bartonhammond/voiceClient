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
    return loading == true
        ? buildSpinner(context)
        : icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    RaisedButton.icon(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      color: Color(0xff00bcd4),
                      onPressed: onPressed,
                      icon: icon,
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      label: buildText(
                        text,
                        context,
                      ),
                    ),
                  ])
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      color: Color(0xff00bcd4),
                      onPressed: onPressed,
                      padding: EdgeInsets.all(5),
                      child: loading
                          ? buildSpinner(context)
                          : buildText(
                              text,
                              context,
                            ),
                    )
                  ]);
  }
}
