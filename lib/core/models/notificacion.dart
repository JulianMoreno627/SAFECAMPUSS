enum TipoNotificacion { alerta, reporte, ia, sistema }

extension TipoNotificacionX on TipoNotificacion {
  String get label {
    switch (this) {
      case TipoNotificacion.alerta:  return 'Alerta';
      case TipoNotificacion.reporte: return 'Reporte';
      case TipoNotificacion.ia:      return 'SafeBot IA';
      case TipoNotificacion.sistema: return 'Sistema';
    }
  }

  static TipoNotificacion fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'alerta':  return TipoNotificacion.alerta;
      case 'reporte': return TipoNotificacion.reporte;
      case 'ia':      return TipoNotificacion.ia;
      default:        return TipoNotificacion.sistema;
    }
  }
}

class Notificacion {
  final String id;
  final TipoNotificacion tipo;
  final String titulo;
  final String cuerpo;
  final bool leida;
  final DateTime createdAt;
  final String? reporteId;

  const Notificacion({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.cuerpo,
    this.leida = false,
    required this.createdAt,
    this.reporteId,
  });

  factory Notificacion.fromMap(Map<String, dynamic> map) {
    return Notificacion(
      id: map['id']?.toString() ?? '',
      tipo: TipoNotificacionX.fromString(map['tipo']?.toString()),
      titulo: map['titulo']?.toString() ?? '',
      cuerpo: map['cuerpo']?.toString() ?? map['mensaje']?.toString() ?? '',
      leida: map['leida'] == true || map['leida'] == 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      reporteId: map['reporte_id']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'tipo': tipo.label.toLowerCase(),
        'titulo': titulo,
        'cuerpo': cuerpo,
        'leida': leida,
        'created_at': createdAt.toIso8601String(),
        if (reporteId != null) 'reporte_id': reporteId,
      };

  Notificacion marcarLeida() => Notificacion(
        id: id,
        tipo: tipo,
        titulo: titulo,
        cuerpo: cuerpo,
        leida: true,
        createdAt: createdAt,
        reporteId: reporteId,
      );

  String get tiempoTranscurrido {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
