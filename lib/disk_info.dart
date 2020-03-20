import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import './filesize.dart';
import 'package:disk_space/disk_space.dart';
import './task.dart';

getDiskSpaceInfo() async {
  return {
    "free": await DiskSpace.getFreeDiskSpaceInBytes,
    "total": await DiskSpace.getTotalDiskSpaceInBytes
  };
}

class DiskInfo extends StatefulWidget {
  DiskInfo(this._globalEventBus);
  EventBus _globalEventBus;
  @override
  _DiskInfoState createState() => _DiskInfoState(_globalEventBus);
}

class _DiskInfoState extends State<DiskInfo> {
  _DiskInfoState(this._globalEventBus);
  EventBus _globalEventBus;
  Map<String, int> info = {"free": 0, "total": 0};
  calculate() {
    getDiskSpaceInfo().then((info) {
      setState(() {
        this.info = info;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    this._globalEventBus.on<TaskState>().listen((event) {
      if(event.type == TaskType.clean){
        calculate();
      }
      
    });
    calculate();
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
