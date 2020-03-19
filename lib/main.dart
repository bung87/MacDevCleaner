import 'dart:ffi';

import 'package:flutter/material.dart';
import './spinner.dart';
import "package:flutter_brand_icons/flutter_brand_icons.dart";
import 'package:url_launcher/url_launcher.dart';
import './applist.dart';
import 'package:disk_space/disk_space.dart';
import './filesize.dart';
import 'package:event_bus/event_bus.dart';
import './events.dart';
import 'apps/mac.dart';

EventBus eventBus = EventBus();

void main() {
  runApp(new MaterialApp(home: new ExampleWidget()));
}

getDiskSpaceInfo() async {
  return {
    "free": await DiskSpace.getFreeDiskSpaceInBytes,
    "total": await DiskSpace.getTotalDiskSpaceInBytes
  };
}

class DiskInfo extends StatefulWidget {
  @override
  _DiskInfoState createState() => _DiskInfoState();
}

class _DiskInfoState extends State<DiskInfo> {
  Map<String, int> info = {"free": 0, "total": 0};
  @override
  void initState() {
    
    super.initState();
    getDiskSpaceInfo().then((info) {
      setState(() {
        this.info = info;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Container(
            alignment: Alignment.centerLeft,
            width: 60,
            child: Image(
                image: AssetImage('assets/icons/Disk-HD-Apple-icon.png'),
                width: 48,
                height: 48)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Total:"),
                  Text(fileSizeHumanReadable(this.info["total"]))
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Free:"),
                    Text(fileSizeHumanReadable(this.info["free"]))
                  ],
                ))
          ],
        )
      ],
    ));
  }
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
          new Positioned(left: 20, top: 80, child: DiskInfo()),
          new Positioned(
              child: new AppList(eventBus),
              left: 20,
              top: 160,
              width: 300,
              height: 600),
          new Positioned(
              left: mediaQueryData.size.width / 2 - 180,
              top: mediaQueryData.size.height / 2,
              child: new RaisedButton.icon(
                color: Colors.lightBlue,
                padding: EdgeInsets.only(left: 10, right: 20),
                // padding:EdgeInsets.symmetric(vertical:0,horizontal:10),
                icon: new Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.white),
                label: new Text("Scan",
                    style: new TextStyle(fontSize: 20, color: Colors.white)),
                onPressed: () {
                  eventBus.fire(UserInter("scan"));
                },
              )),
        ]));
  }
}
