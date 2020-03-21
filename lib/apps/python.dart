import '../task.dart';
import 'package:event_bus/event_bus.dart';
import 'dart:io';
import '../utils.dart';
import '../filesize.dart';
import 'dart:convert';
import './python_utils.dart';
import 'dart:isolate';

void runGetDirectorySize(SendPort sendPort) {
  var dir = filesInDirectoryWithDepth(
      Directory(userHome), FileSystemEntityType.directory, 0, 3);
  sendPort.send(dir);
}

class PythonTask extends Task {
  String app = "python";
  PythonTask(EventBus _globalBus) : super(_globalBus) {}

  @override
  scan() async {
    // final String workon = Platform.environment["WORKON_HOME"];
    // var p = Process.start("printenv", [r"WORKON_HOME"]);
    // p.then((process) {
    //   process.stdout.transform(utf8.decoder).listen((workon) {
    //     _scan(workon.trim());
    //   });
    // }).catchError((e){
    //   this.eventBus.fire(TaskData(this.app, e.toString()));
    // }

    // );

    ReceivePort receivePort = ReceivePort();
    var isolate = await Isolate.spawn(runGetDirectorySize, receivePort.sendPort,
        onExit: receivePort.sendPort);

    receivePort.listen((data) {
      _scan(data);
      isolate.kill(priority: 0);
    });
  }

  _scan(workon) async {
    final days = new DateTime.now().subtract(new Duration(days: 90));
    var dirs = await filesInDirectory(workon, FileSystemEntityType.directory);
    int total = 0;

    Stream.fromIterable(dirs)
        .skipWhile((element) => element.statSync().accessed.isAfter(days))
        .asyncMap((event) async {
      var size = await directorySize(event);
      var data = {"dir": event, "size": size};
      return data;
    }).listen((event) {
      this.cache.add(event);
      this.eventBus.fire(TaskData(this.app, event["dir"].path.toString()));
      total += event["size"];
    }).onDone(() {
      if (total == 0) {
        this.eventBus.fire(TaskData(this.app, "empty"));
      } else {
        this.eventBus.fire(TaskData(this.app, fileSizeHumanReadable(total)));
      }
      this
          .eventBus
          .fire(TaskState(this.app, TaskStatus.done, TaskType.scan, total));
    });
  }
}
