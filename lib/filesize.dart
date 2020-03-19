
import 'dart:math';

const units = ["bytes","KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
const marketingDivider = 1000;
String fileSizeHumanReadable(dynamic size){
  var key = 0;
  if (size <= 0) {
    return "";
  }
  while(key < units.length){
    final div = pow(marketingDivider,key);
    if(size < div){
      // num r = size.toInt() >> ( (key - 1)  * 10);
      double r = size.toInt() / pow(marketingDivider,key - 1);
      return "${r.toStringAsFixed(r.truncateToDouble() == r ? 0 : 2)} ${units[key - 1]}";
    }
    key++;
  }
  return "$size bytes";
}
