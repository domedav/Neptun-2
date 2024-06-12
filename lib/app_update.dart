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
    if(DataCache.getIsInstalledFromGPlay() != 0){
      return; // app is from gplay, and gplay updates are handled differently
    }
    final cacheTime = await getInt('ObsolteAppVerUpdateCacheTime') ?? -1;

    if((DateTime.now().millisecondsSinceEpoch - cacheTime) > const Duration(hours: 24).inMilliseconds || // once a day update check
        await Connectivity().checkConnectivity() == ConnectivityResult.none) // only check for updates, if there is internet
        {return;}

    final appUpdateHelper = await Generic.getAppUpdateHelper();
    final currentBuildNumber = int.parse((await PackageInfo.fromPlatform()).buildNumber);
    // akik nem szeretnek frissíteni, kicsit erőltetős módon perszuáljuk őket
    if((appUpdateHelper!.minAppVer ?? 0) > currentBuildNumber){
      PopupWidgetHandler(mode: 7, callback: (_){
        if(!Platform.isAndroid){
          return;
        }
        launchUrl(Uri.parse(appUpdateHelper!.updateUrl ?? 'https://github.com/domedav/Neptun-2/releases'), mode: LaunchMode.externalApplication);
      },
          onCloseCallback: ()async{
            if((appUpdateHelper!.minDisableVer ?? 0) > currentBuildNumber){
              if(Platform.isAndroid){
                await launchUrl(Uri.parse(appUpdateHelper!.updateUrl ?? 'https://github.com/domedav/Neptun-2/releases'), mode: LaunchMode.externalApplication);
              }
              exit(0);
            }
          });
      PopupWidgetHandler.doPopup(context, blur: blur, closeBlur: closeBlur);
      await saveInt('ObsolteAppVerUpdateCacheTime', DateTime.now().millisecondsSinceEpoch); // save last checked update time
      return;
    }
  }
}