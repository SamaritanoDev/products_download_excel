import 'dart:convert';
import 'package:app_product_new/product/domain/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveDatainSharedPreferences {
  Future<void> saveProducts(List<Producto> productos) async {
    final prefs = await SharedPreferences.getInstance();

    // Serializa la lista de productos a JSON
    final productosEnString = productos.map((producto) {
      return json.encode(producto.toJson());
    }).toList();

    // Guarda la lista completa en SharedPreferences
    await prefs.setStringList('productos', productosEnString);
  }

  Future<List<Producto>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productosEnString = prefs.getStringList('productos') ?? [];

    print(
        'Productos cargados desde SharedPreferences DESDE FORM: $productosEnString');

    List<Producto> productos = [];
    for (var productoJson in productosEnString) {
      try {
        // Convertir la cadena JSON en un mapa antes de pasarlo a fromJson
        final Map<String, dynamic> productoMap = jsonDecode(productoJson);
        productos.add(Producto.fromJson(productoMap));
      } catch (e) {
        print('Error parsing product JSON: $e');
      }
    }
    return productos;
  }
}
