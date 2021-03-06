import 'dart:io'
    show Directory, File, FileSystemEntity, FileSystemEntityType, Platform;

final String userHome =
    Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

filesInDirectory(Directory dir, FileSystemEntityType typ) async {
  List<dynamic> files = <dynamic>[];

  if (dir == null || !dir.existsSync()) {
    return [];
  }
  await for (FileSystemEntity entity
      in dir.list(recursive: false, followLinks: false)) {
    FileSystemEntityType type = await FileSystemEntity.type(entity.path);
    if (type == typ) {
      files.add(entity);
    }
  }
  return files;
}

directorySize( dir) async {
  if (!dir.existsSync()) {
    return 0;
  }
  var total = 0;
  if (await FileSystemEntity.type(dir.path, followLinks: false) ==
      FileSystemEntityType.directory) {
    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      FileSystemEntityType type =
          await FileSystemEntity.type(entity.path, followLinks: false);

      if (type == FileSystemEntityType.file) {
        var stat = await entity.stat();
        total += stat.size;
      }
    }
  } else {
    var stat = await dir.stat();
    total += stat.size;
  }

  return total;
}

directorySizeSync(Directory dir) {
  var total = 0;
  for (var entity in dir.listSync(recursive: true, followLinks: false)) {
    FileSystemEntityType type =
        FileSystemEntity.typeSync(entity.path, followLinks: false);

    if (type == FileSystemEntityType.file) {
      var stat = entity.statSync();
      total += stat.size;
    }
  }
  return total;
}
