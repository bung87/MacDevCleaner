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
  // int size;
}

enum TaskType { scan, clean }

enum TaskStatus { process, done, processing }

class TaskState {
  TaskState(this.app, this.status, this.type, this.total);
  TaskStatus status;
  TaskType type;
  String app;
  int total;
}

class Task {
  String app;
  EventBus eventBus = EventBus();
  EventBus _globalBus;
  List<dynamic> cache = [];
  Task(this._globalBus) {
    this._globalBus.on<UserInter>().listen((event) {
      if (event.typ == "scan") {
        try{
          this.scan();
        } on FileSystemException catch(e){
          // does nothing
        }
        
      } else if (event.typ == "clean") {
        this.clean();
      }
    });
  }

  void scan() {}
  void clean() {
    Stream.fromIterable(cache).listen((element) {
      if (element["dir"] is Directory) {
        (element["dir"] as Directory).delete(recursive: true);
      }else{
        element["dir"].delete();
      }
    }).onDone(() {
      this
          .eventBus
          .fire(TaskState(this.app, TaskStatus.done, TaskType.clean, 0));
          this.recalculate();
      
    });
  }

  void recalculate() {
    Stream.fromIterable(cache)
        .asyncMap((event) => directorySize(event["dir"]))
        .reduce((previous, element) => previous + element)
        .then((value) {
          if(value == 0){
            this.eventBus.fire(TaskData(this.app, "empty"));
          }else{
            this.eventBus.fire(TaskData(this.app, fileSizeHumanReadable(value)));
          }
      
      this.cache.clear();
    });
  }
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
  List<dynamic> cache = [];
  DirsCleanTask(this.dirs) {}

  void scan() {
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
        .asyncMap((dir) async {
      var size = directorySizeSync(dir);
      this.cache.add({"dir": dir, "size": size});
      return {"dir": dir.path.toString(), "size": size};
    }).listen((event) {
      int size = event["size"];
      this.eventBus.fire(DirInfo(event["dir"], size));
    },onError:( (e){
      // does nothing;
    })).onDone(() {
      this.eventBus.fire(TaskStatus.done);
    });
  }
}
