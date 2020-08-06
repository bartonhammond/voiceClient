import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'package:provider/provider.dart';

import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';
import 'sign_in_page_mobile.dart';
import 'sign_in_page_tablet.dart';

class SignInPageBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, ValueNotifier<bool> isLoading, __) => SignInPage(
          isLoading: isLoading.value,
          title: Strings.MFV.i18n,
        ),
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage({Key key, this.isLoading, this.title}) : super(key: key);
  final String title;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: SignInPageMobile(key: key, isLoading: isLoading, title: title),
      tablet: SignInPageTablet(key: key, isLoading: isLoading, title: title),
    );
  }
}
