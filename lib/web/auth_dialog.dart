import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:MyFamilyVoice/constants/constants.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/auth_service.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

class AuthDialog extends StatefulWidget {
  @override
  _AuthDialogState createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  AuthService _authService;
  final _formKey = GlobalKey<FormState>();
  TextEditingController textControllerEmail;
  bool _forgotPassword = false;
  bool formReady = false;
  bool _showPassword = false;
  TextEditingController textControllerPassword;

  final int _fontSize = 16;
  final int _size = 20;
  final int _formFieldWidth = 500;
  bool _isRegistering = false;
  bool _isLoggingIn = false;

  String email;
  String password;

  String loginStatus;
  Color loginStringColor = Colors.green;

  String _validateEmail(String value) {
    value = value?.trim();
    if (textControllerEmail.text != null) {
      if (value == null || value.isEmpty) {
        return Strings.authDialogEmailEmpty.i18n;
      } else if (!value.contains(RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))) {
        return Strings.authDialogCorrectEmailAddress.i18n;
      }
    }

    return null;
  }

  String _validatePassword(String value) {
    value = value?.trim();

    if (textControllerEmail.text != null) {
      if (value == null || value.isEmpty) {
        return Strings.authDialogPasswordEmpty.i18n;
      } else if (value.length < 6 || value.length > 10) {
        return Strings.authDialogPasswordLength.i18n;
      }
    }

    return null;
  }

  @override
  void initState() {
    textControllerEmail = TextEditingController();
    textControllerPassword = TextEditingController();

    textControllerEmail.addListener(() {
      setState(() {
        email = textControllerEmail.text;
      });
      _formReady();
    });
    textControllerPassword.addListener(() {
      setState(() {
        password = textControllerPassword.text;
      });
      _formReady();
    });
    textControllerEmail.text = 'admin@myfamilyvoice.com';
    textControllerPassword.text = 'Passw0rd';
    super.initState();
  }

  void _formReady() {
    formReady = false;
    if (_forgotPassword) {
      if (_validateEmail(email) == null) {
        formReady = true;
      }
    } else {
      if (_validateEmail(email) == null &&
          _validatePassword(password) == null) {
        formReady = true;
      }
    }
  }

  Widget getSignupButton() {
    return CustomRaisedButton(
        fontSize: _fontSize.toDouble(),
        key: Key('signupButtonKey'),
        icon: Icon(
          Icons.person_add,
          color: Colors.white,
          size: _size.toDouble(),
        ),
        text: Strings.authDialogRegister.i18n,
        onPressed: !formReady ? null : null // doSignup()

        );
  }

  Future<void> doSignup() async {
    setState(() {});
    if (_validateEmail(textControllerEmail.text) == null &&
        _validatePassword(textControllerPassword.text) == null) {
      setState(() {
        _isRegistering = true;
      });
      await _authService
          .registerWithEmailPassword(
              textControllerEmail.text, textControllerPassword.text)
          .then((result) {
        if (result != null) {
          setState(() {
            loginStatus = Strings.authDialogRegisterSuccess.i18n;
            loginStringColor = Colors.green;
          });
        }
      }).catchError((dynamic error) {
        setState(() {
          loginStatus = Strings.authDialogRegisterFailure.i18n;
          loginStringColor = Colors.red;
        });
      });
    } else {
      setState(() {
        loginStatus = Strings.authDialogEnterEmailPassword.i18n;
        loginStringColor = Colors.red;
      });
    }
    setState(
      () {
        _isRegistering = false;
        textControllerEmail.text = '';
        textControllerPassword.text = '';
      },
    );
  }

  Widget getResetPasswordButton(AuthService _authService) {
    return Flexible(
      flex: 1,
      child: Container(
        width: double.maxFinite,
        child: FlatButton(
          color: Colors.blueGrey[800],
          hoverColor: Colors.blueGrey[900],
          highlightColor: Colors.black,
          onPressed: () async {
            setState(() {});
            if (_validateEmail(textControllerEmail.text) == null &&
                _validatePassword(textControllerPassword.text) == null) {
              setState(() {
                _isRegistering = true;
              });
              await _authService
                  .registerWithEmailPassword(
                      textControllerEmail.text, textControllerPassword.text)
                  .then((result) {
                if (result != null) {
                  setState(() {
                    loginStatus = Strings.authDialogRegisterSuccess.i18n;
                    loginStringColor = Colors.green;
                  });
                }
              }).catchError((dynamic error) {
                setState(() {
                  loginStatus = Strings.authDialogRegisterFailure.i18n;
                  loginStringColor = Colors.red;
                });
              });
            } else {
              setState(() {
                loginStatus = Strings.authDialogEnterEmailPassword.i18n;
                loginStringColor = Colors.red;
              });
            }
            setState(() {
              _isRegistering = false;

              textControllerEmail.text = '';
              textControllerPassword.text = '';
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 15.0,
              bottom: 15.0,
            ),
            child: _isRegistering
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Text(
                    Strings.authDialogRegister,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget getForgotPasswordButton() {
    return _isLoggingIn
        ? CircularProgressIndicator()
        : Column(
            children: [
              SizedBox(
                height: 20,
              ),
              CustomRaisedButton(
                fontSize: _fontSize.toDouble(),
                key: Key('forgotPassworButtonKey'),
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: _size.toDouble(),
                ),
                text: Strings.authDialogSubmit.i18n,
                onPressed: !formReady
                    ? null
                    : () async {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          setState(() {
                            _isLoggingIn = true;
                          });
                          if (_validateEmail(textControllerEmail.text) ==
                              null) {
                            await _authService
                                .sendPasswordReset(textControllerEmail.text)
                                .then((result) {
                              //no problem
                            }).catchError((dynamic error) {
                              setState(() {
                                loginStatus =
                                    Strings.authDialogErrorSendingEmail.i18n;
                                loginStringColor = Colors.red;
                              });
                            });
                          } else {
                            setState(() {
                              loginStatus =
                                  Strings.authDialogPleaseEnterEmail.i18n;
                              loginStringColor = Colors.red;
                            });
                          }
                          setState(() {
                            _isLoggingIn = false;
                          });
                        }
                      },
              ),
              SizedBox(
                height: 20,
              )
            ],
          );
  }

  Widget getLoginButton() {
    return CustomRaisedButton(
      fontSize: _fontSize.toDouble(),
      key: Key('loginButtonKey'),
      icon: Icon(
        Icons.login,
        color: Colors.white,
        size: _size.toDouble(),
      ),
      text: Strings.authDialogLogin.i18n,
      onPressed: !formReady
          ? null
          : () async {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                setState(() {
                  _isLoggingIn = true;
                });
                await _authService
                    .signInWithEmailPassword(
                        textControllerEmail.text, textControllerPassword.text)
                    .then((user) {
                  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
                  graphQLAuth.setUser(user);
                  //no problem
                }).catchError((dynamic error) {
                  setState(() {
                    loginStatus = Strings.authDialogLoginError.i18n;
                    loginStringColor = Colors.red;
                  });
                });
              } else {
                setState(() {
                  loginStatus = Strings.authDialogEnterEmailPassword.i18n;
                  loginStringColor = Colors.red;
                });
              }
              setState(() {
                _isLoggingIn = false;
                textControllerPassword.text = '';
              });
            },
    );
  }

  Widget getButtons() {
    return _isLoggingIn
        ? CircularProgressIndicator()
        : Column(children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getLoginButton(),
                SizedBox(width: 20),
                getSignupButton(),
              ],
            ),
            SizedBox(
              height: 20,
            )
          ]);
  }

  @override
  Widget build(BuildContext context) {
    _authService = Provider.of<AuthService>(context, listen: false);
    return Dialog(
      key: Key('dialogkey'),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 400,
            child: getForm(),
          ),
        ),
      ),
    );
  }

  Widget getForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              Strings.MFV.i18n,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
          ),
          SizedBox(height: 30),
          Container(
            width: _formFieldWidth.toDouble(),
            margin: const EdgeInsets.only(right: 10, left: 10),
            child: TextFormField(
              // focusNode: textFocusNodeEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              controller: textControllerEmail,
              autofocus: false,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xff00bcd4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Constants.backgroundColor,
                    width: 2.0,
                  ),
                ),
                hintStyle: TextStyle(color: Constants.backgroundColor),
                border: const OutlineInputBorder(),
                filled: true,
                hintText: Strings.emailHint,
                labelText: Strings.emailLabel.i18n,
                labelStyle: TextStyle(color: Constants.backgroundColor),
              ),
              validator: (value) {
                return _validateEmail(value);
              },
            ),
          ),
          SizedBox(height: 20),
          _forgotPassword
              ? Container()
              : Container(
                  width: _formFieldWidth.toDouble(),
                  margin: const EdgeInsets.only(right: 10, left: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    controller: textControllerPassword,
                    obscureText: !_showPassword,
                    autofocus: false,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: Color(0xff00bcd4),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: Color(0xff00bcd4),
                          width: 2.0,
                        ),
                      ),
                      hintStyle: TextStyle(color: Constants.backgroundColor),
                      border: const OutlineInputBorder(),
                      filled: true,
                      labelText: Strings.authDialogPassword.i18n,
                      hintText: Strings.authDialogPasswordLength.i18n,
                      labelStyle: TextStyle(
                        color: Constants.backgroundColor,
                      ),
                    ),
                    validator: (value) {
                      return _validatePassword(value);
                    },
                  ),
                ),
          _forgotPassword
              ? Container()
              : Row(children: [
                  SizedBox(width: 25),
                  Checkbox(
                    value: _showPassword,
                    onChanged: (value) {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                  Text(Strings.authDialogShowPassword.i18n,
                      style: TextStyle(fontSize: 12)),
                ]),
          _forgotPassword ? getForgotPasswordButton() : getButtons(),
          loginStatus != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 20.0,
                    ),
                    child: Text(
                      loginStatus,
                      style: TextStyle(
                        color: loginStringColor,
                        fontSize: 14,
                        // letterSpacing: 3,
                      ),
                    ),
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(
              left: 40.0,
              right: 40.0,
            ),
            child: Container(
              height: 1,
              width: double.maxFinite,
              color: Colors.blueGrey[200],
            ),
          ),
          SizedBox(height: 30),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                InkWell(
                  child: _forgotPassword
                      ? Text(
                          Strings.authDialogLoginOrRegister.i18n,
                          style: TextStyle(
                            color: Color(0xff00bcd4),
                            fontSize: 16.0,
                          ),
                        )
                      : Text(
                          Strings.authDialogForgotPassword.i18n,
                          style: TextStyle(
                            color: Color(0xff00bcd4),
                            fontSize: 16.0,
                          ),
                        ),
                  onTap: () {
                    setState(() {
                      _forgotPassword = !_forgotPassword;
                      loginStatus = '';
                    });
                    _formReady();
                  },
                ),
              ])),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              Strings.authDialogTermAndPrivacy.i18n,
              maxLines: 2,
              style: TextStyle(
                color: Theme.of(context).textTheme.subtitle2.color,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
