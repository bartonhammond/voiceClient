import 'package:flutter/material.dart';

class FeaturesTile extends StatelessWidget {
  const FeaturesTile({this.title, this.description});
  final String title, description;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: <Widget>[
          Image.asset(
            'test.png',
            width: 40,
            height: 40,
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
          ),
          SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }
}
