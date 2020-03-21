import '../task.dart';
import 'package:event_bus/event_bus.dart';
import 'dart:io';
import '../utils.dart';
import '../filesize.dart';
import 'dart:convert';
import './ruby_utils.dart';
import 'dart:isolate';

// final RegExp re = new RegExp(r'\.rvm/gems/ruby\-(\d+\.\d+(?:\.\d+)?)/cache');

void runGetDirectorySize(SendPort sendPort) {
  filesInDirectoryWithDepth(
      Directory(userHome), FileSystemEntityType.directory, 0, 4, sendPort);
}

class RubyTask extends Task {
  String app = "ruby";
  RubyTask(EventBus _globalBus) : super(_globalBus) {}

  @override
  scan() async {
    // final String workon = Platform.environment["GEM_HOME"];
    // var p = Process.start("rvm", [r"gemdir"]);
    // p.then((process) {
    //   process.stdout.transform(utf8.decoder).listen((workon) {
    //     _scan(workon.trim());
    //   });
    // }).catchError((e){
    //   this.eventBus.fire(TaskData(this.app, e.toString()));
    // } );
    ReceivePort receivePort = ReceivePort();
    var isolate = await Isolate.spawn(runGetDirectorySize, receivePort.sendPort);

    receivePort.listen((data) {
      isolate.kill(priority: 0);
      _scan(data);
      
    });
  }

  _scan(out) async {
    if(out == null){
      return;
    }
    // final days = new DateTime.now().subtract(new Duration(days: 90));
    // var dirs = await filesInDirectory(out, FileSystemEntityType.file);
    int total = 0;
    // Stream.fromFuture(dirs)
    out.list(recursive: false, followLinks: false)
        // .skipWhile((element) => element.statSync().accessed.isAfter(days))
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
