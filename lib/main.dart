import 'package:flutter/material.dart';
import './spinner.dart';
import "package:flutter_brand_icons/flutter_brand_icons.dart";
import 'package:url_launcher/url_launcher.dart';
import './applist.dart';
import 'package:event_bus/event_bus.dart';
import './disk_info.dart';

import './mainbtn.dart';


EventBus eventBus = EventBus();


void main() {
  runApp(new MaterialApp(home: new ExampleWidget()));
}

class ExampleWidget extends StatelessWidget {
 
  @override
  Widget build(BuildContext context) {
    Spinner bigCircle = Spinner(800, Colors.greenAccent.withAlpha(128), 0);
    Spinner bigCircle2 = Spinner(600, Colors.lightBlue.withAlpha(128), 500);

    const String url = "https://github.com/bung87/MacDevCleaner";
    //final renderObject = context?.findRenderObject(); // only after build
    final mediaQueryData = MediaQuery.of(context);
    return new Material(
        color: Colors.white,
        child: new Stack(children: <Widget>[
          new Positioned(right: -350, top: 10, child: bigCircle),
          new Positioned(right: -300, top: 40, child: bigCircle2),
          new Positioned(
              left: 20,
              top: 20,
              child: new Text("MacDevCleaner",
                  style: new TextStyle(fontSize: 30))),
          new Positioned(
              right: 20,
              bottom: 20,
              child: new FlatButton.icon(
                  highlightColor: Colors.lightBlue,
                  onPressed: () => {launch(url)},
                  icon: new Icon(BrandIcons.github),
                  label: new Text(url))),
          new Positioned(left: 20, top: 80, child: DiskInfo(eventBus)),
          new Positioned(
              child: new AppList(eventBus),
              left: 20,
              top: 160,
              width: 300,
              height: 600),
          new Positioned(
            left: mediaQueryData.size.width / 2 - 180,
            top: mediaQueryData.size.height / 2,
            child: new MainBtn(eventBus),
          )
        ]));
  }
}
