import 'package:MyFamilyVoice/common_widgets/getDialog.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/web/feature_slider.dart';
import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  YoutubePlayerController _controller;

  @override
  void initState() {
    _controller = YoutubePlayerController(
      initialVideoId: 'xfBFZPsx8UA', //whoami
      params: const YoutubePlayerParams(
        playlist: [
          'za8jb5dDBq0', //Registration
          '8CMrwyZ9mFg', //Users Tab
          'OAIeQqVePIQ', //Notices
          'kegALu9x5_U', //Story
          '6a4AuphhnQ8', //Stories tab
          'Bs6A6Cqy7M0', //Distribution
          'PQKEdjpD6LA', //Tagging
          'pzkQ7uJ-jxM', //Books
        ],
        autoPlay: false,
        showControls: false,
        showFullscreenButton: true,
      ),
    );
    _controller.onEnterFullscreen = () {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    };
    _controller.onExitFullscreen = () {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      Future.delayed(const Duration(seconds: 1), () {
        _controller.play();
      });
      Future.delayed(const Duration(seconds: 5), () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      });
      super.initState();
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: const [0.1, 0.5, 0.7, 0.9],
          colors: [
            Colors.red[100],
            Colors.red[500],
            Colors.purple[100],
            Colors.purple[500],
          ],
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        body: OrientationBuilder(
          builder: (context, orientation) {
            return ListView(
              children: <Widget>[
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  alignment: WrapAlignment.center,
                  runSpacing: 10.0,
                  spacing: 10.0,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          Image.asset(
                            'mfv-500x500.png',
                            height: 200.0,
                            width: 200.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Strings.MFV.i18n,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 60.0,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Strings.landingUltimate.i18n,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10.0,
                              bottom: 10.0,
                              left: 20.0,
                              right: 20.0,
                            ),
                            child: Text(
                              Strings.landingUltimateSub.i18n,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    fontSize: 20.0,
                                    height: 1.8,
                                    fontWeight: FontWeight.w300,
                                  ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'googleComing.png',
                                height: 100.0,
                                width: 170.0,
                              ),
                              Image.asset(
                                'comingApple.png',
                                height: 100.0,
                                width: 170.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                FeatureSlider(),
                _buildFeatureOne(
                  Strings.landingFeatureOne.i18n,
                  Strings.landingFeatureOneSub.i18n,
                  Strings.landingFeatureOneExplain.i18n,
                  'GrandadHS.png',
                ),
                _buildFeatureTwo(
                    orientation,
                    Strings.landingFeatureTwo.i18n,
                    Strings.landingFeatureTwoSub.i18n,
                    Strings.landingFeatureTwoExplain.i18n,
                    'joanAndWade.png'),
                _buildFeatureThree(
                    Strings.landingFeatureThree.i18n,
                    Strings.landingFeatureThreeSub.i18n,
                    Strings.landingFeatureThreeExplain.i18n,
                    'FindFriends.png'),
                _buildFeatureFour(
                  orientation,
                  Strings.landingFeatureFour.i18n,
                  Strings.landingFeatureFourSub.i18n,
                  Strings.landingFeatureFourExplain.i18n,
                  'momHS.png',
                ),
                _buildFeatureYouTube('CHECK OUT THE INSTRUCTIONAL VIDEOS',
                    'Learn how easy it is to use My Family Voice'),
                Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.height * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        Image.asset(
                          'mfv-500x500.png',
                          height: 200.0,
                          width: 200.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            Strings.MFV.i18n,
                            style:
                                Theme.of(context).textTheme.headline6.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 60.0,
                                    ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            Strings.landingUltimateExplain.i18n,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(color: Colors.grey),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'googleComing.png',
                              height: 100.0,
                            ),
                            Image.asset(
                              'comingApple.png',
                              height: 100.0,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              DateTime.now().year.toString(),
                            ),
                            Icon(
                              Icons.copyright,
                              size: 16.0,
                            ),
                            Text(
                              Strings.MFV.i18n,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                getDialog(context, 'Terms', 'terms.html');
                              },
                              child: Text(
                                'Terms',
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                getDialog(context, 'Privacy', 'policy.html');
                              },
                              child: Text(
                                'Privacy',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureOne(
      String title, String sub, String explain, String image) {
    return Container(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        alignment: WrapAlignment.center,
        runSpacing: 10.0,
        spacing: 10.0,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.height * 0.5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline3.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(sub,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontSize: 20.0,
                              height: 1.8,
                              fontWeight: FontWeight.w300,
                            )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(explain,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontSize: 20.0,
                              height: 1.8,
                              fontWeight: FontWeight.w300,
                            )),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTwo(
    Orientation orientation,
    String title,
    String sub,
    String explain,
    String image,
  ) {
    return orientation == Orientation.portrait
        ? Container(
            color: Colors.blue.shade100,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              runSpacing: 10.0,
              spacing: 10.0,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.height * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(fontSize: 15.0, color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(sub,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    fontSize: 20.0,
                                    height: 1.8,
                                    fontWeight: FontWeight.w300,
                                  )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(explain,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    fontSize: 20.0,
                                    height: 1.8,
                                    fontWeight: FontWeight.w300,
                                  )),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * 0.6,
                  ),
                ),
              ],
            ))
        : Container(
            color: Colors.blue.shade100,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              runSpacing: 10.0,
              spacing: 10.0,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * 0.6,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.height * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(sub,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    fontSize: 20.0,
                                    height: 1.8,
                                    fontWeight: FontWeight.w300,
                                  )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(explain,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    fontSize: 20.0,
                                    height: 1.8,
                                    fontWeight: FontWeight.w300,
                                  )),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ));
  }

  Widget _buildFeatureThree(
      String title, String sub, String explain, String image) {
    return Container(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        alignment: WrapAlignment.center,
        runSpacing: 10.0,
        spacing: 10.0,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.height * 0.5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline3.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(sub,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontSize: 20.0,
                              height: 1.8,
                              fontWeight: FontWeight.w300,
                            )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(explain,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontSize: 20.0,
                              height: 1.8,
                              fontWeight: FontWeight.w300,
                            )),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureFour(
    Orientation orientation,
    String title,
    String sub,
    String explain,
    String image,
  ) {
    return orientation == Orientation.portrait
        ? Container(
            color: Colors.blue.shade100,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              runSpacing: 10.0,
              spacing: 10.0,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.height * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(sub,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    fontSize: 20.0,
                                    height: 1.8,
                                    fontWeight: FontWeight.w300,
                                  )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(explain,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    fontSize: 20.0,
                                    height: 1.8,
                                    fontWeight: FontWeight.w300,
                                  )),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * 0.6,
                  ),
                ),
              ],
            ))
        : Container(
            color: Colors.blue.shade100,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              runSpacing: 10.0,
              spacing: 10.0,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * 0.6,
                  ),
                ),
                Container(
                  color: Colors.blue.shade100,
                  width: MediaQuery.of(context).size.height * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(sub,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    fontSize: 20.0,
                                    height: 1.8,
                                    fontWeight: FontWeight.w300,
                                  )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(explain,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    fontSize: 20.0,
                                    height: 1.8,
                                    fontWeight: FontWeight.w300,
                                  )),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildFeatureYouTube(
    String title,
    String sub,
  ) {
    const player = YoutubePlayerIFrame();
    return Container(
      height: 750.0,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        alignment: WrapAlignment.center,
        runSpacing: 10.0,
        spacing: 10.0,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline3.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(sub,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontSize: 20.0,
                              height: 1.8,
                              fontWeight: FontWeight.w300,
                            )),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text('Be sure to click on the playlist  ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                      fontSize: 20.0,
                                      height: 1.8,
                                      fontWeight: FontWeight.w300,
                                    )),
                            Icon(Icons.playlist_play),
                            Text(' to see all available videos',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                      fontSize: 18.0,
                                      height: 1.8,
                                      fontWeight: FontWeight.w300,
                                    )),
                          ])),
                ],
              ),
            ),
          ),
          Container(
            height: 750,
            width: 800,
            child: YoutubePlayerControllerProvider(
              // Passing controller to widgets below.
              controller: _controller,
              child: SizedBox(
                height: 950,
                width: 800,
                child: ListView(
                  children: const [
                    player,
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
