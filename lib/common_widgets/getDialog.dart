import 'package:MyFamilyVoice/app/legal/legal_page.dart';
import 'package:flutter/material.dart';

Future<Widget> getDialog(
    BuildContext context, String title, String fileName) async {
  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.only(left: 25, right: 25),
        title: Center(child: Text(title)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        content: Container(
          height: MediaQuery.of(context).size.height * .5,
          width: MediaQuery.of(context).size.width * .5,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                LegalPage(fileName),
              ],
            ),
          ),
        ),
      );
    },
  );
}
