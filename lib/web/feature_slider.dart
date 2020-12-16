import 'package:MyFamilyVoice/web/carousel.dart';
import 'package:MyFamilyVoice/web/feature_tile.dart';
import 'package:MyFamilyVoice/web/general_data.dart';
import 'package:MyFamilyVoice/web/model/feature_tile_model.dart';
import 'package:MyFamilyVoice/web/responsive_widget.dart';
import 'package:flutter/material.dart';

class FeatureSlider extends StatefulWidget {
  @override
  _FeatureSliderState createState() => _FeatureSliderState();
}

class _FeatureSliderState extends State<FeatureSlider> {
  List<FeatureTileModel> features1 = <FeatureTileModel>[];
  List<FeatureTileModel> features2 = <FeatureTileModel>[];

  List<String> screenshots = <String>[];

  @override
  void initState() {
    features1 = getFeaturesTiles1();
    features2 = getFeaturesTiles2();

    for (int i = 0; i < features1.length; i++) {
      screenshots.add(features1[i].getImagePath());
    }
    for (int i = 0; i < features2.length; i++) {
      screenshots.add(features2[i].getImagePath());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade100,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Text(
            'Fun for the whole family',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline3
                .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(
            height: 8,
          ),
          Text('Everyone has a Story to tell, Every Story has something to say',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    fontSize: 20.0,
                    height: 1.8,
                    fontWeight: FontWeight.w300,
                  )),
          SizedBox(
            height: 16,
          ),
          Container(
            child: ResponsiveWidget(
              largeScreen: Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    child: ListView.builder(
                        itemCount: features1.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return FeaturesTile(
                            title: features1[index].getTitle(),
                            description: features1[index].getDesc(),
                          );
                        }),
                  ),
                  Container(
                    height: 700,
                    width: MediaQuery.of(context).size.width / 3,
                    child: Carousel(screenshots),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    child: ListView.builder(
                        itemCount: features2.length,
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return FeaturesTile(
                            title: features2[index].getTitle(),
                            description: features2[index].getDesc(),
                          );
                        }),
                  ),
                ],
              ),
              smallScreen: Column(
                children: <Widget>[
                  Container(
                    child: ListView.builder(
                        itemCount: features1.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return FeaturesTile(
                            title: features1[index].getTitle(),
                            description: features1[index].getDesc(),
                          );
                        }),
                  ),
                  SizedBox(
                    height: 650,
                    width: 350,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: screenshots.length,
                        itemBuilder: (context, index) {
                          return Image.asset(screenshots[index]);
                        }),
                  ),
                  Container(
                    child: ListView.builder(
                        itemCount: features2.length,
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return FeaturesTile(
                            title: features2[index].getTitle(),
                            description: features2[index].getDesc(),
                          );
                        }),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
