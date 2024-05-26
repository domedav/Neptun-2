import 'dart:io';
import 'package:neptun2/storage.dart';
import 'package:vibration/vibration.dart';

class AppHaptics{
  static bool _vibrationStateCached = true;

  static void initialise(){
    Future.delayed(Duration.zero, ()async{
      final value = await DataCache.getNeedsHaptics()!;
      if(value){
        await setVibrationState(true);
        return;
      }
      _vibrationStateCached = value;
    });
  }

  static Future<bool> _canAppVibrate()async{
    if(!Platform.isAndroid){
      return false;
    }
    final canVibrate = await Vibration.hasVibrator();
    final settingsVibrate = await DataCache.getNeedsHaptics()!;
    if(!canVibrate! || !settingsVibrate){
      return false;
    }
    return true;
  }

  static Future<void> setVibrationState(bool canVibrate)async{
    await DataCache.setNeedsHaptics(canVibrate ? 1 : 0);
    _vibrationStateCached = canVibrate;
  }

  static Future<bool> getVibrationState()async{
    return await DataCache.getNeedsHaptics()!;
  }

  static bool getVibrationStateSync(){
    return _vibrationStateCached;
  }

  static void lightImpact(){
    Future.delayed(Duration.zero, ()async{
      final canVibrate = await _canAppVibrate();
      if(!canVibrate){
        return;
      }
      await Vibration.vibrate(pattern: [0, 10], intensities: [1]);
    });
  }

  static void mediumImpact(){
    Future.delayed(Duration.zero, ()async{
      final canVibrate = await _canAppVibrate();
      if(!canVibrate){
        return;
      }
      await Vibration.vibrate(duration: 16, pattern: [0, 16], intensities: [15]);
    });
  }

  static void heavyImpact(){
    Future.delayed(Duration.zero, ()async{
      final canVibrate = await _canAppVibrate();
      if(!canVibrate){
        return;
      }
      await Vibration.vibrate(duration: 35, pattern: [0, 35], intensities: [30]);
    });
  }


  static void textEditingImpact(){
    Future.delayed(Duration.zero, ()async{
      final canVibrate = await _canAppVibrate();
      if(!canVibrate){
        return;
      }
      await Vibration.vibrate(duration: 1, pattern: [0, 1], intensities: [1]);
    });
  }

  static void attentionImpact(){
    Future.delayed(Duration.zero, ()async{
      final canVibrate = await _canAppVibrate();
      if(!canVibrate){
        return;
      }
      await Vibration.vibrate(duration: 195, pattern: [0, 35, 125, 35], intensities: [20, 10]);
    });
  }

  static void attentionLightImpact(){
    Future.delayed(Duration.zero, ()async{
      final canVibrate = await _canAppVibrate();
      if(!canVibrate){
        return;
      }
      await Vibration.vibrate(duration: 130, pattern: [0, 15, 100, 15], intensities: [10, 5]);
    });
  }

  static void bounceImpact(){
    Future.delayed(Duration.zero, ()async{
      final canVibrate = await _canAppVibrate();
      if(!canVibrate){
        return;
      }
      await Vibration.vibrate(duration: 365, pattern: [0, 45, 75, 35, 70, 25, 45, 15, 25, 10, 10, 10, 5, 5], intensities: [50, 40, 30, 20, 10, 10, 10, 10, 5]);
    });
  }
}