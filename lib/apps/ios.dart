
import '../task.dart';
import '../utils.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:event_bus/event_bus.dart';
import '../filesize.dart';

class IosTask extends Task{
   String  app = "ios";
  IosTask(EventBus _globalBus) : super(_globalBus) {
    // 3、移除模拟器的临时文件
  // 影响：可重新生成；如果需要保留较新版本的模拟器，但tmp文件夹很大。放心删吧，tmp文件夹里的内容是不重要的。在iOS Device中，存储空间不足时，tmp文件夹是可能被清空的。
    filesInDirectory(Directory("~/Library/Application Support/iPhone Simulator/"),FileSystemEntityType.directory).then( (dirs) {
              dirs.forEach( ( dir)  {
              this.dirs.add(path.join(dir.absolute.toString(),"tmp"));
              });
    });
  }

  List<String> dirs = [
    // 1、移除对旧设备的支持
  // 影响：可重新生成；再连接旧设备调试时，会重新自动生成。我移除了4.3.2, 5.0, 5.1等版本的设备支持。
  "~/Library/Developer/Xcode/iOS DeviceSupport",

  // 2、移除旧版本的模拟器支持
  // 影响：不可恢复；如果需要旧版本的模拟器，就需要重新下载了。我移除了4.3.2, 5.0, 5.1等旧版本的模拟器。
  // 路径：~/Library/Application Support/iPhone Simulator

  // 4、移除模拟器中安装的Apps
  // 影响：不可恢复；对应的模拟器中安装的Apps被清空了，如果不需要就删了吧。
  // 路径：~/Library/Application Support/iPhone Simulator/6.1/Applications (以iOS Simulator 6.1为例)

  // 5、移除Archives
  // 影响：不可恢复；Adhoc或者App Store版本会被删除。建议备份dSYM文件夹
  // 路径：~/Library/Developer/Xcode/Archives

  // 6、移除DerivedData
  // 影响：可重新生成；会删除build生成的项目索引、build输出以及日志。重新打开项目时会重新生成，大的项目会耗费一些时间。
  "~/Library/Developer/Xcode/DerivedData",

  // 7、移除旧的Docsets
  // 影响：不可恢复；将删除旧的Docsets文档
  // 路径：~/Library/Developer/Shared/Documentation/DocSets

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
      if(event == TaskStatus.done){
        if(total == 0){
          this.eventBus.fire(TaskData(this.app,"empty"));
        }else{
          this.cache.addAll(task.cache);
          this.eventBus.fire(TaskData(this.app,fileSizeHumanReadable(total)));
        }
        this.eventBus.fire(TaskState(this.app,TaskStatus.done,TaskType.scan,total));
        
        total = 0;
      }
    });
    task.scan();
  }

  // @override
  // clean(){
    
  // }
  
}

