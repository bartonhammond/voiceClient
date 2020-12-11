import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

List<Widget> checkProxy(
  GraphQLAuth graphQLAuth,
  BuildContext context,
  VoidCallback onRemoveProxy,
) {
  if (graphQLAuth.isProxy) {
    return [
      IconButton(
        icon: Icon(
          Icons.person_add_disabled,
          size: 30,
        ),
        color: Colors.red,
        onPressed: () async {
          final bool quitProxy = await PlatformAlertDialog(
            title: 'Quit Proxy',
            content: graphQLAuth.getUserMap()['name'],
            defaultActionText: Strings.ok.i18n,
            cancelActionText: Strings.cancel.i18n,
          ).show(context);
          if (quitProxy) {
            await graphQLAuth.removeProxy();
            onRemoveProxy();
            // setState(() {});
          }
        },
      )
    ];
  }
  return null;
}
