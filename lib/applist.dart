import 'package:flutter/material.dart';
import 'dart:io';
import "package:flutter_brand_icons/flutter_brand_icons.dart";

class AppList extends StatefulWidget {
  AppList({Key key}) : super(key: key);

  @override
  _AppListState createState() => _AppListState();
}

class _AppListState extends State<AppList> {
  bool hasNode;
  bool hasPython;
  bool hasRuby;
  static final List<String> entries = ["nodejs", "python", "ruby"];
  Map<String, String> appStates =
      Map.fromIterable(entries, key: (k) => k, value: (v) => "detecting $v");
  initState() {
    super.initState();
    Process.start("node", ["-v"],runInShell:true).then((value) {
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
    Process.start("python", ["--version"],runInShell:true).then((value) {
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
    Process.start("ruby", ["-v"],runInShell:true).then((value) {
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
                        Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(entries[index],
                                textAlign: TextAlign.left)),
                        Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(appStates[entries[index]],
                                textAlign: TextAlign.center))
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
  "nodejs": BrandIcons.nodeDotJs,
  "ruby": BrandIcons.ruby,
  "ios": BrandIcons.apple,
  "python": BrandIcons.python,
  "docker": BrandIcons.docker
};
