import 'dart:convert';
import 'package:app_product_new/product/domain/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductListByDate extends StatefulWidget {
  const ProductListByDate({super.key});

  @override
  State<ProductListByDate> createState() => _ProductListByDateState();
}

class _ProductListByDateState extends State<ProductListByDate> {
  List<Producto> _productos = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productosEnString = prefs.getStringList('productos') ?? [];

    print('Productos cargados desde SharedPreferences: $productosEnString');

    setState(() {
      _productos = productosEnString.map((productoJson) {
        return Producto.fromJson(json.decode(productoJson));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos por Fecha'),
      ),
      body: ListView.builder(
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final producto = _productos[index];
          return ListTile(
            title: Text(producto.nombre),
            subtitle: Text(
              'Precio: ${producto.precio.toStringAsFixed(2)} - Cantidad: ${producto.cantidad}',
            ),
            trailing: Text(
              DateFormat('dd-MM-yyyy').format(producto.fecha),
            ),
          );
        },
      ),
    );
  }
}
