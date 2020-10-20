import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class LegalPage extends StatelessWidget {
  const LegalPage(this.fileName);
  final String fileName;

  Future<String> loadDisclaimerAsset() async {
    return await rootBundle.loadString('assets/$fileName');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadDisclaimerAsset(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final String html = snapshot.data;

          return HtmlWidget(html);
        });
  }
}
