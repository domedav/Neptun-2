import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:neptun2/app_analitics_server_send.dart';
import 'package:neptun2/storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppAnalitics{
  static const int ERROR = 0;
  static const int INFO = 1;

  static Future<void> sendAnaliticsData(int reportType, String reportData)async{
    if(!DataCache.getAnalyticsEnrolledState()! || !DataCache.getHasNetwork()!){
      return;
    }
    final analiticsData = await _getAnaliticsData(reportType, reportData);
    AppAnaliticsServer.makePostRequest(analiticsData);
  }

  static Future<AnaliticsData> _getAnaliticsData(int reportType, String reportData)async{
    final pkgInfo = (await PackageInfo.fromPlatform());
    final version = "${pkgInfo.version}+${pkgInfo.buildNumber}-${DataCache.getIsInstalledFromGPlay()! != 0 ? "Gplay" : "3rd party"}";
    final institude = DataCache.getInstituteUrl() ?? "No Login";

    if(!Platform.isAndroid){
      return AnaliticsData(userId: "NonAndroidDevice", institude: institude, appVersion: version, reportType: reportType, reportData: reportData);
    }

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    return AnaliticsData(userId: androidInfo.id, institude: institude, appVersion: version, reportType: reportType, reportData: reportData);
  }
}

class AnaliticsData{
  final String userId;
  final String institude;
  final String appVersion;
  final int reportType;
  final String reportData;

  const AnaliticsData({required this.userId, required this.institude, required this.appVersion, required this.reportType, required this.reportData});
}