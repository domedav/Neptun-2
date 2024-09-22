import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:neptun2/storage.dart';
import 'package:path_provider/path_provider.dart' as path;

typedef Callback = void Function(bool);
typedef IcsCallback = void Function(Stream<List<int>>);

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

  static Future<Stream<List<int>>?> openFileReadStream(String path)async{
    final file = File(path);
    if(!await file.exists()){
      return null;
    }
    final stream = file.openRead();
    return stream;
  }
}

class IcsImportHelper{
  static const String ICSFILENAME = 'OfflineUserCalendar.ics';

  static void onCalendarUploadAction(Callback onResult){
    try{
      Future.delayed(Duration.zero, ()async{
        final path = await LocalFileActions.openFilePicker('');
        if(path == null || path.isEmpty){
          onResult(false);
          return;
        }
        final clonePath = await LocalFileActions.cloneFileToTemp(path, IcsImportHelper.ICSFILENAME);
        await DataCache.setICSFileLocation(clonePath);
        await DataCache.setHasICSFile(true);
        onResult(true);
      });
    }
    catch (_){
      onResult(false);
    }
  }

  static Future<bool> streamIcsFileContent(IcsCallback fileStream)async{
    final result = await LocalFileActions.openFileReadStream(DataCache.getICSFileLocation() ?? '');
    if(result == null){
      return false;
    }
    fileStream(result);
    return true;
  }
}