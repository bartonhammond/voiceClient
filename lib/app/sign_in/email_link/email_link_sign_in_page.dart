import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:MyFamilyVoice/app/sign_in/validator.dart';
import 'package:MyFamilyVoice/common_widgets/drawer_widget.dart';
import 'package:MyFamilyVoice/common_widgets/form_submit_button.dart';
import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/common_widgets/platform_exception_alert_dialog.dart';
import 'package:MyFamilyVoice/constants/constants.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/auth_service.dart';
import 'package:MyFamilyVoice/services/firebase_email_link_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailLinkSignInPage extends StatefulWidget {
  const EmailLinkSignInPage({
    Key key,
    @required this.authService,
    @required this.linkHandler,
    this.onSignedIn,
  }) : super(key: key);
  final FirebaseEmailLinkHandler linkHandler;
  final AuthService authService;
  final VoidCallback onSignedIn;

  @override
  _EmailLinkSignInPageState createState() => _EmailLinkSignInPageState();
}

class _EmailLinkSignInPageState extends State<EmailLinkSignInPage> {
  String _email;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RegexValidator _emailSubmitValidator = EmailSubmitRegexValidator();

  final TextEditingController _emailController = TextEditingController();

  StreamSubscription<User> _onAuthStateChangedSubscription;
  @override
  void initState() {
    super.initState();
    // Get email from store initially
    widget.linkHandler.getEmail().then((String email) {
      _email = email ?? '';
      _emailController.value = TextEditingValue(text: _email);
    });
    // Invoke onSignedIn callback if a non-null user is detected
    _onAuthStateChangedSubscription =
        widget.authService.onAuthStateChanged.listen((User user) {
      if (user != null) {
        if (widget.onSignedIn != null && mounted) {
          widget.onSignedIn();
        }
      }
    });
  }

  @override
  void dispose() {
    _onAuthStateChangedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _sendEmailLink() async {
    try {
      // Send link
      await widget.linkHandler.sendSignInWithEmailLink(
        email: _email,
        url: Constants.firebaseProjectURL,
        handleCodeInApp: true,
        packageName: 'online.myfamilyvoice.mobile',
        androidInstallIfNotAvailable: true,
        androidMinimumVersion: '21',
      );
      // Tell user we sent an email
      PlatformAlertDialog(
        title: Strings.checkYourEmail.i18n,
        content: Strings.activationLinkSent.i18n,
        defaultActionText: Strings.ok.i18n,
      ).show(context);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: Strings.errorSendingEmail.i18n,
        exception: e,
      ).show(context);
    }
  }

  Future<void> _validateAndSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      await _sendEmailLink();
    }
  }

  Future<Locale> getDeviceLocal(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String locale = prefs.getString('locale');
    if (locale != null) {
      return Locale(locale);
    }
    return Locale('en');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDeviceLocal(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xff00bcd4),
              title: Text(Strings.MFV.i18n),
            ),
            drawer: getDrawer(context, showLogout: false),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Card(
                    child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: widget.linkHandler.isLoading,
                    builder: (_, isLoading, __) => _buildForm(isLoading),
                  ),
                )),
              ),
            ),
            backgroundColor: Colors.grey[200],
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildForm(bool isLoading) {
    final TextStyle hintStyle =
        TextStyle(fontSize: 25.0, color: Colors.grey[400]);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Strings.submitEmailAddressLink.i18n,
            style: TextStyle(fontSize: 20.0, color: Colors.black),
          ),
          SizedBox(height: 16.0),
          Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            child: TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                ),
                border: const OutlineInputBorder(),
                filled: true,
                labelText: Strings.emailLabel.i18n,
                hintText: Strings.emailHint.i18n,
                hintStyle: hintStyle,
              ),
              enabled: !isLoading,
              keyboardType: TextInputType.emailAddress,
              validator: (String value) {
                return _emailSubmitValidator.isValid(value)
                    ? null
                    : Strings.invalidEmailErrorText.i18n;
              },
              inputFormatters: <TextInputFormatter>[
                ValidatorInputFormatter(
                    editingValidator: EmailEditingRegexValidator()),
              ],
              autocorrect: true,
              keyboardAppearance: Brightness.light,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.done,
              onSaved: (String email) => _email = email,
              onEditingComplete: _validateAndSubmit,
            ),
          ),
          SizedBox(height: 16.0),
          FormSubmitButton(
            key: Key('sendLinkButton'),
            onPressed: isLoading ? null : _validateAndSubmit,
            loading: isLoading,
            text: Strings.sendActivationLink.i18n,
            icon: Icon(
              MdiIcons.email,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
