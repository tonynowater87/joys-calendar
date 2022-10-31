import 'package:package_info_plus/package_info_plus.dart';

class AppInfoProvider {
  Future<PackageInfo> getVersionName() {
    return PackageInfo.fromPlatform();
  }
}
