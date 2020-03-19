import 'dart:collection';

import 'package:MacDevCleaner/apps/nodejs.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import "package:flutter_brand_icons/flutter_brand_icons.dart";
import './task.dart';
import './apps/mac.dart';
import './utils.dart';
import './filesize.dart';

class AppList extends StatefulWidget {
  final EventBus _globalEventBus;
  AppList(this._globalEventBus, {Key key}) : super(key: key);

  @override
  _AppListState createState() => _AppListState(this._globalEventBus);
}

class _AppListState extends State<AppList> {
  _AppListState(this._globalEventBus);
  bool hasNode;
  bool hasPython;
  bool hasRuby;
  EventBus _globalEventBus;
  static final List<String> entries = [
    "Mac",
    "ios",
    "nodejs",
    "python",
    "ruby"
  ];
  Map<String, String> appStates = Map.fromIterable(entries.skip(2),
      key: (k) => k, value: (v) => "detecting $v");

  Map<String, String> taskStates =
      Map.fromIterable(entries, key: (k) => k, value: (v) => "");

  initState() {
    super.initState();
    new MacTask(_globalEventBus).eventBus.on<TaskData>().listen((event) {
      setState(() {
        this.taskStates[event.app] = event.info;
        print(event.info);
      });
    });
    // int total = 0;
    var task = new NodeTask(_globalEventBus);
  
    task.eventBus.on<TaskData>().listen((event) {
      // total += Directory(event.info).statSync().size;
      print(event.info);
      setState(() {
        this.taskStates[event.app] = event.info;

      });
    });
    
    

    appStates.addAll({"Mac": "", "ios": ""});
    const iphone = "~/Library/Application Support/iPhone Simulator/";
    const xcode = "~/Library/Developer/Xcode/";

    Stream.fromFutures([Directory(xcode).exists(), Directory(iphone).exists()])
        .any((element) => element == true)
        .then((value) => setState(() {
              this.appStates["ios"] = "detected";
            }));

    Process.start("node", ["-v"], runInShell: true).then((value) {
      setState(() {
        this.hasNode = true;
        this.appStates["nodejs"] = "installed";
      });
    }).catchError((e) {
      setState(() {
        this.hasNode = false;
        this.appStates["nodejs"] = "not installed";
      });
    });
    Process.start("python", ["--version"], runInShell: true).then((value) {
      setState(() {
        this.hasPython = true;
        this.appStates["python"] = "installed";
      });
    }).catchError((e) {
      setState(() {
        this.hasPython = false;
        this.appStates["python"] = "not installed";
      });
    });
    Process.start("ruby", ["-v"], runInShell: true).then((value) {
      setState(() {
        this.hasRuby = true;
        this.appStates["ruby"] = "installed";
      });
    }).catchError((e) {
      print(e);
      setState(() {
        this.hasRuby = false;
        this.appStates["ruby"] = "not installed";
      });
    });
  }

  Widget build(BuildContext context) {
    // Map<String,String> appStates = { for (var key in entries) key:"detecting ${key}"};
    final list = ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
            height: 50,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(iconMap[entries[index]]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(entries[index],
                                    textAlign: TextAlign.left)),
                            Column(
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Text(
                                        entries[index] == "Mac"
                                            ? ""
                                            : "(${appStates[entries[index]]})",
                                        style:
                                            TextStyle(color: Colors.grey[400]),
                                        textAlign: TextAlign.left)),
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(taskStates[entries[index]],
                                      style: TextStyle(fontSize: 10),
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis),
                                )
                              ],
                            )
                          ],
                        )
                      ])
                ]));
      },
      separatorBuilder: (BuildContext context, int index) =>
          const Divider(thickness: 0.3),
    );
    return new Container(child: list);
  }
}

const iconMap = {
  "Mac": BrandIcons.apple,
  "nodejs": BrandIcons.nodeDotJs,
  "ruby": BrandIcons.ruby,
  "ios": BrandIcons.apple,
  "python": BrandIcons.python,
  "docker": BrandIcons.docker
};
