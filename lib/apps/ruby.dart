import '../task.dart';
import 'package:event_bus/event_bus.dart';
import 'dart:io';
import '../utils.dart';
import '../filesize.dart';
import 'dart:convert';

class RubyTask extends Task {
  String app = "ruby";
  RubyTask(EventBus _globalBus) : super(_globalBus) {}

  @override
  scan() async {
    // final String workon = Platform.environment["GEM_HOME"];
    var p = Process.start("/usr/bin/printenv", [r"GEM_HOME"]);
    p.then((process) {
      process.stdout.transform(utf8.decoder).listen((workon) {
        _scan(workon.trim());
      });
    }).catchError((e){
      this.eventBus.fire(TaskData(this.app, e.toString()));
    }
      
    );
    // _scan(workon.trim());
  }

  _scan(String workon) async {
    final days = new DateTime.now().subtract(new Duration(days: 90));
    var dirs = await filesInDirectory(
        Directory(workon), FileSystemEntityType.directory);
    int total = 0;
    Stream.fromIterable(dirs)
        .skipWhile((element) => element.statSync().accessed.isAfter(days))
        .asyncMap(
            (event) async => {"dir": event, "size": await directorySize(event)})
        .listen((event) {
      print(event);
      this.cache.add(event["dir"]);
      this.eventBus.fire(TaskData(this.app, event["dir"].path.toString()));
      total += event["size"];
    },onError: (e){
      this.eventBus.fire(TaskData(this.app, fileSizeHumanReadable(total)));
      this
          .eventBus
          .fire(TaskState(this.app, TaskStatus.done, TaskType.scan, total));
    }).onDone(() {
      this.eventBus.fire(TaskData(this.app, fileSizeHumanReadable(total)));
      this
          .eventBus
          .fire(TaskState(this.app, TaskStatus.done, TaskType.scan, total));
    });
  }
}
