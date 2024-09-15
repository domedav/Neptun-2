import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart' as path;
class LocalFileActions{

  static Future<String> _getTempDirectory()async{
    return (await path.getTemporaryDirectory()).path;
  }

  static Future<String?> _getDownloadsFolder()async{
    return (await path.getDownloadsDirectory())?.path;
  }

  static Future<String?> openFilePicker(String dialogTitle)async{
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      initialDirectory: await _getDownloadsFolder(),
      type: FileType.custom,
      allowedExtensions: ['.ics', '.ICS', 'ics', 'ICS'],
      allowMultiple: false,
      allowCompression: false,
    );
    return result?.xFiles[0].path;
  }

  static Future<String> cloneFileToTemp(String path, String filename)async{
    final file = File(path);
    final fileBytes = await file.readAsBytes();
    final clone = File((await _getTempDirectory()) + '/' + filename);
    if(await clone.exists()){
      await clone.delete(recursive: false);
    }
    await clone.create(recursive: true);
    await clone.writeAsBytes(fileBytes, flush: true);
    return clone.path;
  }
}

class IcsImportHelper{
  static const String ICSFILENAME = 'OfflineUserCalendar.ics';

  static bool onCalendarUploadAction(){
    try{
      Future.delayed(Duration.zero, ()async{
        final path = await LocalFileActions.openFilePicker('');
        if(path == null || path.isEmpty){
          return false;
        }
        final clonePath = await LocalFileActions.cloneFileToTemp(path, IcsImportHelper.ICSFILENAME);

        return true;
      });
    }
    catch (_){
      return false;
    }
    return false;
  }
}