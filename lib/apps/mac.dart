import '../task.dart';
import '../utils.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:event_bus/event_bus.dart';
import '../filesize.dart';

class MacTask extends Task{
  static String  app = "Mac";
  MacTask(EventBus _globalBus) : super(_globalBus) {
    // application caches
    filesInDirectory(Directory("~/Library/Containers/"),FileSystemEntityType.directory).then( (dirs) {
              dirs.forEach( ( dir)  {
              this.dirs.add(path.join(dir.absolute.toString(),"Data/Library/Caches"));
              });
    });
  }

  List<String> dirs = [
    "~/Library/Preferences/",
    "/Library/Caches/",
    "/Library/logs/",
    "/var/log/",
    "/private/var/folders/",
    "~/Pictures/iPhoto\ Library/iPod\ Photo\ Cache/"
  ];

  @override
  scan(){
    int total = 0;
    var task = new DirsCleanTask(this.dirs);
    task.eventBus.on<DirInfo>().listen( (event ) {
      total += event.size;
      this.eventBus.fire( TaskData(MacTask.app,event.toString() ) );
    });
    task.eventBus.on<TaskStatus>().listen((event) {
      if(event == TaskStatus.done){
        this.eventBus.fire(TaskData(MacTask.app,fileSizeHumanReadable(total)));
        total = 0;
      }
    });
    task.run();
  }
}

// brew cleanup
// gem cleanup
