import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import './events.dart';
import 'task.dart';

class MainBtn extends StatefulWidget {
  EventBus _globalEventBus;
  MainBtn(this._globalEventBus) {}
  @override
  _MainBtnState createState() => _MainBtnState(_globalEventBus);
}

enum btnState { Scan, Scanning, Clean }

class _MainBtnState extends State<MainBtn> {
  EventBus _globalEventBus;
  _MainBtnState(this._globalEventBus) {
    _globalEventBus.on<TaskState>().listen((event) {
      setState(() {
        switch (event.type) {
          case TaskType.scan: //scan done
            this._btnState = btnState.Clean;
            break;
          case TaskType.clean: // clean done
            this._btnState = btnState.Scan;
            break;
          default:
            break;
        }
      });
    });
  }
  btnState _btnState = btnState.Scan;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: new FlatButton.icon(
      color: Colors.lightBlue,
      padding: EdgeInsets.only(left: 10, right: 20),
      // shape: new CircleBorder(),
      // shape: new RoundedRectangleBorder(borderRadius:BorderRadius.circular(50)),
      // padding:EdgeInsets.symmetric(vertical:0,horizontal:10),
      icon: new Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
      label: new Text(_btnState.toString().split(".")[1],
          style: new TextStyle(fontSize: 20, color: Colors.white)),
      onPressed: () {
        switch (_btnState) {
          case btnState.Scan:
            _globalEventBus.fire(UserInter("scan"));
            setState(() {
              _btnState = btnState.Scanning;
            });

            break;
          case btnState.Clean:
            _globalEventBus.fire(UserInter("clean"));
            break;
          default:
            break;
        }

        // eventBus.fire(UserInter("scan"));
      },
    ));
  }
}
