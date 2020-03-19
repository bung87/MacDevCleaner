// 1、移除对旧设备的支持
// 影响：可重新生成；再连接旧设备调试时，会重新自动生成。我移除了4.3.2, 5.0, 5.1等版本的设备支持。
// 路径：~/Library/Developer/Xcode/iOS DeviceSupport

// 2、移除旧版本的模拟器支持
// 影响：不可恢复；如果需要旧版本的模拟器，就需要重新下载了。我移除了4.3.2, 5.0, 5.1等旧版本的模拟器。
// 路径：~/Library/Application Support/iPhone Simulator

// 3、移除模拟器的临时文件
// 影响：可重新生成；如果需要保留较新版本的模拟器，但tmp文件夹很大。放心删吧，tmp文件夹里的内容是不重要的。在iOS Device中，存储空间不足时，tmp文件夹是可能被清空的。
// 路径：~/Library/Application Support/iPhone Simulator/6.1/tmp (以iOS Simulator 6.1为例)

// 4、移除模拟器中安装的Apps
// 影响：不可恢复；对应的模拟器中安装的Apps被清空了，如果不需要就删了吧。
// 路径：~/Library/Application Support/iPhone Simulator/6.1/Applications (以iOS Simulator 6.1为例)

// 5、移除Archives
// 影响：不可恢复；Adhoc或者App Store版本会被删除。建议备份dSYM文件夹
// 路径：~/Library/Developer/Xcode/Archives

// 6、移除DerivedData
// 影响：可重新生成；会删除build生成的项目索引、build输出以及日志。重新打开项目时会重新生成，大的项目会耗费一些时间。
// 路径：~/Library/Developer/Xcode/DerivedData

// 7、移除旧的Docsets
// 影响：不可恢复；将删除旧的Docsets文档
// 路径：~/Library/Developer/Shared/Documentation/DocSets

