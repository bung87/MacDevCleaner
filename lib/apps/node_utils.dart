import 'dart:async';
import 'package:path/path.dart' as path;
import 'dart:io' show Directory, File, FileSystemEntity, FileSystemEntityType;

listWhere(Directory dir) {
  final days = new DateTime.now().subtract(new Duration(days: 90));
  return dir
      .list(recursive: false, followLinks: false)
      .where((event) =>
          FileSystemEntityType.directory ==
          FileSystemEntity.typeSync(event.path, followLinks: false))
      .skipWhile((element) => path.basename(element.path).startsWith("."))
      .skipWhile((element) => element.statSync().accessed.isAfter(days));
}

class NodeModulesSink implements EventSink<FileSystemEntity> {
  Function callback;
  final EventSink<FileSystemEntity> _outputSink;
  NodeModulesSink(this._outputSink, this.callback);

  void add(FileSystemEntity data) {
    if (path.basename(data.path).startsWith(".")) {
      return;
    }
    if (path.basename(data.path) == "node_modules") {
      callback(data);
      return;
    }

    if (data.absolute.toString().split("/").length > 6) {
      return;
    }
    _outputSink.add(data);
  }

  void addError(e, [st]) {
    _outputSink.addError(e, st);
  }

  void close() {
    _outputSink.close();
  }
}

class NodeModulesTransformer
    extends StreamTransformerBase<FileSystemEntity, FileSystemEntity> {
  Function callback;
  NodeModulesTransformer(this.callback) {}

  Stream<FileSystemEntity> bind(Stream stream) =>
      new Stream<FileSystemEntity>.eventTransformed(
          stream, (EventSink sink) => new NodeModulesSink(sink, this.callback));
}

listenListWhere(event, {Function callback}) {
  return listWhere(event)
      .transform(new NodeModulesTransformer(callback))
      .listen((data) => listenListWhere(data, callback: callback));
}

void filesInDirectoryWithDepth(Directory dir, FileSystemEntityType typ,
    int currentLevel, int maxLevel, out) {
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
  if (path.basename(dir.path).startsWith(".")) {
    return;
  }
  if (path.basename(dir.path) == "node_modules" &&
      dir.statSync().accessed.isBefore(days)) {
    out.add(dir);

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
        if (type == typ && !path.basename(entity.path).startsWith(".")) {
          if (path.basename(entity.path) == "node_modules") {
            out.add(entity);

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
              entity, typ, currentLevel + 1, maxLevel, out);
        }
      }
    } catch (e) {}
  }
}
