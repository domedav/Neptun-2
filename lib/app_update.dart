import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:neptun2/storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'API/api_coms.dart';
import 'Misc/popup.dart';

class AppUpdate{
  static Future<void> doUpdateRequest(BuildContext context, VoidCallback? blur, VoidCallback? closeBlur)async{
    final cacheTime = await getInt('ObsoleteAppVerUpdateCacheTime') ?? -1;

    if((DateTime.now().millisecondsSinceEpoch - cacheTime) > const Duration(hours: 24).inMilliseconds || // once a day update check
        await Connectivity().checkConnectivity() == ConnectivityResult.none) // only check for updates, if there is internet
        {return;}

    final appUpdateHelper = await Generic.getAppUpdateHelper();
    final currentBuildNumber = int.parse((await PackageInfo.fromPlatform()).buildNumber);
    // force users to update to latest version
    if((appUpdateHelper!.minAppVer ?? 0) > currentBuildNumber){
      PopupWidgetHandler(mode: 7, callback: (_){
        if(!Platform.isAndroid){
          return;
        }
        if(DataCache.getIsInstalledFromGPlay() != 0){
          launchUrl(Uri.parse('market://details?id=com.domedav.neptun2'), mode: LaunchMode.externalNonBrowserApplication);
          return;
        }
        launchUrl(Uri.parse(appUpdateHelper!.updateUrl ?? 'https://github.com/domedav/Neptun-2/releases'), mode: LaunchMode.externalApplication);
      },
          onCloseCallback: ()async{
            if((appUpdateHelper!.minDisableVer ?? 0) > currentBuildNumber){
              if(Platform.isAndroid){
                if(DataCache.getIsInstalledFromGPlay() != 0){
                  launchUrl(Uri.parse('market://details?id=com.domedav.neptun2'), mode: LaunchMode.externalNonBrowserApplication);
                }
                else{
                  await launchUrl(Uri.parse(appUpdateHelper!.updateUrl ?? 'https://github.com/domedav/Neptun-2/releases'), mode: LaunchMode.externalApplication);
                }
              }
              exit(0);
            }
          });
      PopupWidgetHandler.doPopup(context, blur: blur, closeBlur: closeBlur);
      await saveInt('ObsoleteAppVerUpdateCacheTime', DateTime.now().millisecondsSinceEpoch); // save last checked update time
      return;
    }
  }
}