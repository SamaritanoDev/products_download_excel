import 'dart:io';
import 'package:app_product_new/product/domain/product.dart';
import 'package:app_product_new/product/services/save_data_sahred_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:excel/excel.dart' as excel;
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ExcelServices {
  Future<bool> requestPer(Permission permission) async {
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

  Future<void> saveProductsToExcel(BuildContext contextRef) async {
    try {
      // Verificar los permisos de escritura en el almacenamiento externo
      if (await requestPer(Permission.storage) == true) {
        print('Permiso concedido');
      } else {
        print('Permiso no concedido');
        return;
      }

      // Cargar el archivo de Excel existente desde los activos
      final SaveDatainSharedPreferences saveData =
          SaveDatainSharedPreferences();
      // Cree un libro de Excel a partir de la plantilla
      var file = "assets/plantilla_ventas.xlsx";
      var bytes = File(file).readAsBytesSync();
      var workbook = Excel.decodeBytes(bytes);

      // Obtenga la hoja de trabajo de "ventas"
      var worksheet = workbook.sheets['ventas'];

      // Cargar productos desde SharedPreferences
      List<Producto> productos = await saveData.loadProducts();

      // Agregar encabezados a la hoja de trabajo
      worksheet?.appendRow(
        [
          const excel.TextCellValue('Item'),
          const excel.TextCellValue('Nombre Producto'),
          const excel.TextCellValue('Precio'),
          const excel.TextCellValue('Cantidad'),
          const excel.TextCellValue('Monto'),
        ],
      );

      // Agregar datos de objetos `Producto`
      for (var i = 0; i < productos.length; i++) {
        var producto = productos[i];
        worksheet?.appendRow([
          excel.IntCellValue(i + 1),
          excel.TextCellValue(producto.nombre),
          excel.DoubleCellValue(producto.precio),
          excel.IntCellValue(producto.cantidad),
          excel.DoubleCellValue(producto.precio * producto.cantidad),
        ]);
      }

      //leer valores de archivos excel
      for (var table in workbook.tables.keys) {
        print(table);
        print(workbook.tables[table]!.maxColumns);
        print(workbook.tables[table]!.maxRows);
        for (var row in workbook.tables[table]!.rows) {
          print("${row.map((e) => e?.value)}");
        }
      }

      // Obtener el directorio de almacenamiento externo
      String externalStoragePath = await getExternalStoragePath();
      print('Directorio de almacenamiento externo: $externalStoragePath');

      // Combinar el directorio de almacenamiento externo con el nombre del archivo
      String excelFileName =
          'ventas_${DateTime.now().toString().replaceAll(RegExp(r'[^\w\s\.]'), '_')}.xlsx';
      String excelFilePath = '$externalStoragePath/$excelFileName';
      print('Ruta de archivo: $excelFilePath');

      // Guardar el archivo de Excel modificado en el almacenamiento externo
      List<int>? encodedExcel = workbook.encode();
      await File(excelFilePath).writeAsBytes(encodedExcel!);
    } catch (e) {
      print("Error: $e");
      // Mostrar un mensaje de error
      showDialog(
        context: contextRef,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('Se produjo un error al guardar los datos: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextRef),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> checkFileExists() async {
    // Obtener el directorio de almacenamiento externo
    String externalStoragePath = await getExternalStoragePath();
    print('Directorio de almacenamiento externo: $externalStoragePath');

    // Combinar la ruta del directorio con el nombre del archivo
    String excelFileName =
        'ventas_${DateTime.now().toString().replaceAll(RegExp(r'[^\w\s\.]'), '_')}.xlsx';
    String excelFilePath = '$externalStoragePath/$excelFileName';
    print('Ruta de archivo: $excelFilePath');

    // Verificar si el archivo existe
    return File(excelFilePath).exists();
  }
}
