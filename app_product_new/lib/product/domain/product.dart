class Producto {
  String nombre;
  double precio;
  int cantidad;
  DateTime fecha;

  Producto({
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.fecha,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      nombre: json['nombre'] as String,
      precio: json['precio'] as double,
      cantidad: json['cantidad'] as int,
      fecha: DateTime.parse(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String(),
    };
  }
}
