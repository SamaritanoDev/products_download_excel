import 'package:app_product_new/product/domain/product.dart';
import 'package:app_product_new/product/presentation/product_list.dart';
import 'package:app_product_new/product/services/excel_services.dart';
import 'package:app_product_new/product/services/save_data_sahred_preferences.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class FormProduct extends StatefulWidget {
  const FormProduct({super.key});

  @override
  State<FormProduct> createState() => _FormProductState();
}

class _FormProductState extends State<FormProduct> {
  final _formKey = GlobalKey<FormState>();
  final _controladorNombre = TextEditingController();
  final _controladorPrecio = TextEditingController();
  final _controladorCantidad = TextEditingController();
  final ExcelServices excelHelper = ExcelServices();
  final SaveDatainSharedPreferences saveData = SaveDatainSharedPreferences();

  void saveExcel() async {
    await excelHelper.saveProductsToExcel(context);
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      // Crea un nuevo objeto Producto
      final producto = Producto(
        nombre: _controladorNombre.text,
        precio: double.parse(_controladorPrecio.text),
        cantidad: int.parse(_controladorCantidad.text),
        fecha: DateTime.now(),
      );

      // Espera a que se carguen los productos
      List<Producto> productosGuardados = await saveData.loadProducts();

      // Agrega el nuevo producto a la lista
      productosGuardados.add(producto);

      // Actualiza la lista en SharedPreferences
      saveData.saveProducts(productosGuardados);

      // Limpia los campos del formulario
      _controladorNombre.clear();
      _controladorPrecio.clear();
      _controladorCantidad.clear();

      // Muestra un mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto guardado correctamente'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            saveExcel();

            // Verificar la existencia del archivo después de guardarlo
            await excelHelper.checkFileExists();
            // Abrir el archivo después de guardarlo
            await openExcelFile();
          },
          icon: const Icon(Icons.save),
        ),
        title: const Text('Formulario de Producto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductListByDate(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _controladorNombre,
                decoration:
                    const InputDecoration(labelText: 'Nombre del producto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el nombre del producto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controladorPrecio,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el precio del producto';
                  }
                  try {
                    double.parse(value);
                    return null;
                  } catch (e) {
                    return 'Ingrese un precio válido';
                  }
                },
              ),
              TextFormField(
                controller: _controladorCantidad,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa la cantidad del producto';
                  }
                  try {
                    int.parse(value);
                    return null;
                  } catch (e) {
                    return 'Ingrese una cantidad válida';
                  }
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  _saveProduct();
                },
                child: const Text('Guardar producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openExcelFile() async {
    // Obtener la ruta del archivo
    String excelFilePath = await excelHelper.getExcelFilePath();
    // Abrir el archivo utilizando open_file
    OpenFile.open(excelFilePath);
  }

}
