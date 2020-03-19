import '../task.dart';
import '../utils.dart';
import 'dart:io';
import 'package:event_bus/event_bus.dart';
import '../filesize.dart';
import 'dart:async';

class NodeTask extends Task {
  static String app = "nodejs";
  NodeTask(EventBus _globalBus) : super(_globalBus) {}

  @override
  scan() {
    String userHome =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

    var out = [];
    filesInDirectoryWithDepth(
        Directory(userHome), FileSystemEntityType.directory, 0, 3, out);
    
    var total = 0;
    var stream = Stream.fromIterable(out).asyncMap((element) async {
      var size = await directorySize(element);
      total += size;
      return {"name": element.path, "size": size};
    });
    stream.listen((event) {
      print(event);
      this.eventBus.fire(TaskData(NodeTask.app, event["name"]));
    }).onDone(() {
      print("done");
      this.eventBus.fire(TaskData(NodeTask.app, fileSizeHumanReadable(total)));
    });
  }
}
