class ContactoEmergencia {
  final String id;
  final String nombre;
  final String telefono;
  final String? relacion;

  const ContactoEmergencia({
    required this.id,
    required this.nombre,
    required this.telefono,
    this.relacion,
  });

  factory ContactoEmergencia.fromMap(Map<String, dynamic> map) {
    return ContactoEmergencia(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      telefono: map['telefono']?.toString() ?? '',
      relacion: map['relacion']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'telefono': telefono,
        if (relacion != null) 'relacion': relacion,
      };

  String get iniciales {
    final parts = nombre.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  ContactoEmergencia copyWith({
    String? nombre,
    String? telefono,
    String? relacion,
  }) {
    return ContactoEmergencia(
      id: id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      relacion: relacion ?? this.relacion,
    );
  }
}
