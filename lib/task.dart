import 'dart:io';
import './utils.dart';
import 'package:event_bus/event_bus.dart';
import './filesize.dart';
import './events.dart';
import 'dart:async';

class TaskData {
  TaskData(this.app, this.info);
  String app;
  String info;
  
}

enum TaskStatus {
  process, done
}


class Task {
  EventBus eventBus = EventBus();
  EventBus _globalBus;
  Task(this._globalBus) {
    this._globalBus.on<UserInter>().listen((event) {
      if (event.typ == "scan") {
        this.scan();
      }
    });
  }

  void scan() {}
}

class DirInfo {
  String name;
  int size;
  DirInfo(this.name, this.size) {}
  toString() {
    return '$name ${fileSizeHumanReadable(size)}';
  }
}

class DirsCleanTask {
  List<String> dirs;
  EventBus eventBus = EventBus();
  DirsCleanTask(this.dirs) {}
 
  void run() {
    final concate =
        new StreamTransformer.fromHandlers(handleData: (data, sink) {
      data.forEach((dir) {
        sink.add(dir);
      });
    });

    Stream.fromIterable(this.dirs)
        .asyncMap((event) =>
            filesInDirectory(Directory(event), FileSystemEntityType.directory))
        .transform(concate)
        .asyncMap((dir) async =>
            {"dir": dir.path.toString(), "stat": await dir.stat()})
        .listen((event) {
          int size = event["stat"].size;
          this.eventBus.fire(DirInfo(event["dir"], size));
    }).onDone(() {
      this.eventBus.fire(TaskStatus.done);
    });
  }
}
