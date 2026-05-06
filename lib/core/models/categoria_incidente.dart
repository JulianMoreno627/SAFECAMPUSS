class CategoriaIncidente {
  final int id;
  final String nombre;
  final String? icono;
  final String? color;

  const CategoriaIncidente({
    required this.id,
    required this.nombre,
    this.icono,
    this.color,
  });

  factory CategoriaIncidente.fromMap(Map<String, dynamic> map) {
    return CategoriaIncidente(
      id: (map['id'] as num?)?.toInt() ?? 0,
      nombre: map['nombre']?.toString() ?? 'Otro',
      icono: map['icono']?.toString(),
      color: map['color']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'icono': icono,
    'color': color,
  };
}
