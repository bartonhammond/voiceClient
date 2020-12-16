import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Carousel extends StatefulWidget {
  const Carousel(this.imgList);
  final List<String> imgList;
  @override
  State<StatefulWidget> createState() {
    return _CarouselState();
  }
}

class _CarouselState extends State<Carousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CarouselSlider(
        items: imageSliders(),
        options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            height: 650,
            //aspectRatio: 2.0,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            }),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.imgList.map((url) {
          final index = widget.imgList.indexOf(url);
          return Container(
            width: 8.0,
            height: 8.0,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == index
                  ? Color.fromRGBO(0, 0, 0, 0.9)
                  : Color.fromRGBO(0, 0, 0, 0.4),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  List<Widget> imageSliders() {
    return widget.imgList
        .map(
          (item) => Container(
            child: Container(
                //margin: EdgeInsets.all(5.0),
                child: Stack(
              children: <Widget>[
                Image.asset(
                  item,
                  fit: BoxFit.fitHeight,
                ),
              ],
            )),
          ),
        )
        .toList();
  }
}
