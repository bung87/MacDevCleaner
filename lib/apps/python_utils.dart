
import 'package:path/path.dart' as path;
import 'dart:io' show Directory, File, FileSystemEntity, FileSystemEntityType;

 filesInDirectoryWithDepth(Directory dir, FileSystemEntityType typ,
    int currentLevel, int maxLevel) {
  final days = new DateTime.now().subtract(new Duration(days: 90));
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
 
  if (path.basename(dir.path) == ".virtualenvs" &&
      dir.statSync().accessed.isBefore(days)) {

    return dir;
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
          if (path.basename(entity.path) == ".virtualenvs") {

            return entity;
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
            continue;
          }
          filesInDirectoryWithDepth(
              entity, typ, currentLevel + 1, maxLevel);
        }
      }
    } catch (e) {}
  }
}
