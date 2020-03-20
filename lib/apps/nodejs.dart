import '../task.dart';
import '../node_utils.dart';
import '../utils.dart';
import 'dart:io';
import 'package:event_bus/event_bus.dart';
import '../filesize.dart';
import 'dart:async';
import 'dart:isolate';

final String userHome =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  

void runGetDirectorySize(SendPort sendPort) {
  List<Directory> out = [];
  filesInDirectoryWithDepth(Directory(userHome), FileSystemEntityType.directory, 0, 3,out);
  for (var element in out){
     var size = directorySizeSync(element);
    sendPort.send({"name": element.path, "size": size});
  }
  
}

class NodeTask extends Task {
   String app = "nodejs";
  NodeTask(EventBus _globalBus) : super(_globalBus) {}

  @override
  scan() async {
    await scanIsolate();
  }

  // @override
  // clean(){
    
  // }

  /// using isolate
  scanIsolate() async {
    ReceivePort receivePort = ReceivePort();
    var isolate =
        await Isolate.spawn(runGetDirectorySize, receivePort.sendPort,onExit:receivePort.sendPort );
    var total = 0;
    receivePort.listen((data) {
      if(data != null){
        this.cache.add({"dir":Directory(data["name"]),"size":data["size"]});
        this.eventBus.fire(TaskData(this.app, data["name"]));
        total += data["size"];
      }else{
         if(total == 0){
          this.eventBus.fire(TaskData(this.app,"empty"));
        }else{
          this.eventBus.fire(TaskData(this.app, fileSizeHumanReadable(total)));
        }
        this.eventBus.fire(TaskState(this.app,TaskStatus.done,TaskType.scan,total));
        total = 0;
      }
      
    });
  }

  /// using micro tasks
  scanStream() {
    List<Directory> out = [];
  filesInDirectoryWithDepth(Directory(userHome), FileSystemEntityType.directory, 0, 3,out);
    var total = 0;
    var stream =
        Stream.fromIterable(out).asyncMap((element) async {
      var size = await directorySize(element);
      total += size;
      return {"name": element.path, "size": size};
    });
    stream.listen((event) {
      print(event);
      this.eventBus.fire(TaskData(this.app, event["name"]));
    }).onDone(() {
      print("done");
      this.eventBus.fire(TaskData(this.app, fileSizeHumanReadable(total)));
    });
  }
}
