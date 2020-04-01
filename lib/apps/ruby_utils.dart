import 'package:path/path.dart' as path;
import 'dart:io' show Directory, File, FileSystemEntity, FileSystemEntityType;
import 'dart:isolate';

final RegExp re = new RegExp(r'\.rvm/gems/ruby\-(\d+\.\d+(?:\.\d+)?)/cache');

filesInDirectoryWithDepth(Directory dir, FileSystemEntityType typ,
    int currentLevel, int maxLevel,SendPort sendPort)  {

  if ([
        "Documents",
        "Applications",
        "Desktop",
        "Movies",
        "Music",
        "Pictures",
        "Public"
      ].indexOf(path.basename(dir.path)) !=
      -1) {
    return;
  }

  if (re.hasMatch(dir.path) ) {
    sendPort.send(dir);

    return;
  }
  if (currentLevel > maxLevel) {
    return;
  } else {
    try {
      for (FileSystemEntity entity
          in dir.listSync(recursive: false, followLinks: false)) {
        FileSystemEntityType type =
            FileSystemEntity.typeSync(entity.path, followLinks: false);
        if (type == typ) {
          if (re.hasMatch(entity.path)) {
            sendPort.send(entity);

            return;
          }
          if ([
                "Documents",
                "Applications",
                "Desktop",
                "Movies",
                "Music",
                "Pictures",
                "Public"
              ].indexOf(path.basename(dir.path)) !=
              -1) {
            return;
          }
          filesInDirectoryWithDepth(
              entity, typ, currentLevel + 1, maxLevel,sendPort);
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
