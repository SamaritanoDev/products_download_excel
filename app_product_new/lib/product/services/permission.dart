import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService3{
  Future<bool> requestStoragePermission(Permission permission) async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if (build.version.sdkInt >= 30) {
      var re = await Permission.manageExternalStorage.request();
      if (re.isGranted) {
        return true;
      } else {
        return false;
      }
    }
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<String> getExcelFilePath() async {
    // Obtener el directorio de almacenamiento externo
    String externalStoragePath = await getExternalStoragePath();
    // Combinar la ruta del directorio con el nombre del archivo
    String excelFileName = 'pesos_niños_modificado.xlsx';
    return '$externalStoragePath/$excelFileName';
  }

   Future<String> getExternalStoragePath() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      return directory!.path;
    } else if (Platform.isIOS) {
      // En iOS, se recomienda usar el directorio de documentos compartidos
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else {
      throw UnsupportedError(
          "El almacenamiento externo no es compatible en esta plataforma");
    }
  }
}


class PermissionsService{
  Future<bool> requestStoragePermission() async {
    // Check for Android 13 (SDK 33) or higher
    if (Platform.isAndroid &&
        await DeviceInfoPlugin()
            .androidInfo
            .then((info) => info.version.sdkInt >= 33)) {
      return true; // No need to request permission on Android 13+
    }

    var status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.storage.request();
    if (result == PermissionStatus.granted) {
      return true;
    }

    return false;
  }
}
