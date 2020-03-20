import '../task.dart';
import '../utils.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:event_bus/event_bus.dart';
import '../filesize.dart';

class MacTask extends Task{
   String  app = "Mac";
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
      
      this.eventBus.fire( TaskData(this.app,event.toString() ) );
    });
    task.eventBus.on<TaskStatus>().listen((event) {
       if(total == 0){
          this.eventBus.fire(TaskData(this.app,"empty"));
        }else{
          this.eventBus.fire(TaskData(this.app,fileSizeHumanReadable(total)));
        }
        this.cache.addAll(task.cache);
        this.eventBus.fire(TaskState(this.app,TaskStatus.done,TaskType.scan,total));
        total = 0;
    });
    task.scan();
  }

  // @override
  // clean(){
    
  // }
}

// brew cleanup
// gem cleanup
