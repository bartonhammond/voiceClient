import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                              'My Family Voice',
                              style: GoogleFonts.quicksand(
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 60.0,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'The Ultimate Family Experience',
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
                              'My Family Voice is an app for your family to record their audio stories to share with your family forever',
                              textAlign: TextAlign.center,
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
                _buildFeatureOne(),
                _buildFeatureTwo(orientation),
                _buildFeatureThree(),
                _buildFeatureFour(orientation),
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
                            'Try My Family Voice',
                            style: GoogleFonts.quicksand(
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 60.0,
                                  ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Discover interesting stories, some you never heard of, told by your own family.',
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
                              '2020 ',
//                            style: Theme.of(context).textTheme.headline6,
                            ),
                            Icon(
                              Icons.copyright,
                              size: 16.0,
                            ),
                            Text(
                              ' My Family Voice',
//                            style: Theme.of(context).textTheme.headline6,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            FlatButton(
                              onPressed: () {},
                              child: Text(
                                'Terms',
//                              style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            FlatButton(
                              onPressed: () {},
                              child: Text(
                                'Privacy',
//                              style: Theme.of(context).textTheme.headline6,
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

  Widget _buildFeatureOne() {
    return Container(
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
                      'LISTEN TO THEIR STORIES',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(fontSize: 15.0, color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Stories about pictures telling the family history',
                      style: Theme.of(context).textTheme.headline3.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Have Grandad and Grammy record their history for the grandkids to listen to',
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontSize: 18.0,
                            height: 1.8,
                            fontWeight: FontWeight.w300,
                          ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'GrandadHS.png',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTwo(Orientation orientation) {
    return orientation == Orientation.portrait
        ? Wrap(
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
                          'The Whole Family is invited',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontSize: 15.0, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Every one can record, everyone can listen',
                          style: Theme.of(context).textTheme.headline3.copyWith(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'All the stories are audio so that no one has to type.  The comments are also in audio.  And messages are audio too!',
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontSize: 18.0,
                                height: 1.8,
                                fontWeight: FontWeight.w300,
                              ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'joanAndWade.png',
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.6,
                ),
              ),
            ],
          )
        : Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            alignment: WrapAlignment.center,
            runSpacing: 10.0,
            spacing: 10.0,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'joanAndWade.png',
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
                          'The Whole Family is Invited',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontSize: 15.0, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Every one can record, everyone can listen',
                          style: Theme.of(context).textTheme.headline3.copyWith(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'All the stories are audio so that no one has to type.  The comments are also in audio.  And messages are audio too!',
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontSize: 18.0,
                                height: 1.8,
                                fontWeight: FontWeight.w300,
                              ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildFeatureThree() {
    return Container(
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
                      'FIND FRIENDS AND FAMILY',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(fontSize: 15.0, color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Distinquish Family for personal stories',
                      style: Theme.of(context).textTheme.headline3.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'You can search for new Friends using their names and home.  Some Friends might also be Family',
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontSize: 18.0,
                            height: 1.8,
                            fontWeight: FontWeight.w300,
                          ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'FindFriends.png',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureFour(Orientation orientation) {
    return orientation == Orientation.portrait
        ? Wrap(
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
                          'QUICKLY SELECT EXISTING PICTURES OR TAKE ONE',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontSize: 15.0, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'You can use the gallery images or use the camera to take a picture',
                          style: Theme.of(context).textTheme.headline3.copyWith(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'When you select your picture, you can crop it, adjust its position, and reframe it.  Easily too.',
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontSize: 18.0,
                                height: 1.8,
                                fontWeight: FontWeight.w300,
                              ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'momHS.png',
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.6,
                ),
              ),
            ],
          )
        : Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            alignment: WrapAlignment.center,
            runSpacing: 10.0,
            spacing: 10.0,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'momHS.png',
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
                          'QUICKLY SELECT EXISTING PICTURES OR TAKE ONE',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontSize: 15.0, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'You can use the gallery images or use the camera to take a picture',
                          style: Theme.of(context).textTheme.headline3.copyWith(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'When you select your picture, you can crop it, adjust its position, and reframe it.  Easily too.',
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontSize: 18.0,
                                height: 1.8,
                                fontWeight: FontWeight.w300,
                              ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}
