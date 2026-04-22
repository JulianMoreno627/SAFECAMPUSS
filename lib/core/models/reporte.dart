import 'package:flutter/material.dart';

enum NivelUrgencia { bajo, medio, alto, critico }

enum TipoIncidente {
  robo,
  acoso,
  personaSospechosa,
  iluminacion,
  pelea,
  vandalismo,
  accidente,
  otro,
}

extension NivelUrgenciaX on NivelUrgencia {
  String get label {
    switch (this) {
      case NivelUrgencia.bajo:    return 'bajo';
      case NivelUrgencia.medio:   return 'medio';
      case NivelUrgencia.alto:    return 'alto';
      case NivelUrgencia.critico: return 'critico';
    }
  }

  String get labelCapitalized =>
      label[0].toUpperCase() + label.substring(1);

  int get puntos {
    switch (this) {
      case NivelUrgencia.critico: return 10;
      case NivelUrgencia.alto:    return 5;
      case NivelUrgencia.medio:   return 2;
      case NivelUrgencia.bajo:    return 1;
    }
  }

  static NivelUrgencia fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'critico':
      case 'crítico': return NivelUrgencia.critico;
      case 'alto':    return NivelUrgencia.alto;
      case 'medio':   return NivelUrgencia.medio;
      default:        return NivelUrgencia.bajo;
    }
  }
}

extension TipoIncidenteX on TipoIncidente {
  String get label {
    switch (this) {
      case TipoIncidente.robo:              return 'Robo';
      case TipoIncidente.acoso:             return 'Acoso';
      case TipoIncidente.personaSospechosa: return 'Persona sospechosa';
      case TipoIncidente.iluminacion:       return 'Iluminación';
      case TipoIncidente.pelea:             return 'Pelea';
      case TipoIncidente.vandalismo:        return 'Vandalismo';
      case TipoIncidente.accidente:         return 'Accidente';
      case TipoIncidente.otro:              return 'Otro';
    }
  }

  IconData get icon {
    switch (this) {
      case TipoIncidente.robo:              return Icons.phone_android_rounded;
      case TipoIncidente.acoso:             return Icons.warning_rounded;
      case TipoIncidente.personaSospechosa: return Icons.person_off_rounded;
      case TipoIncidente.iluminacion:       return Icons.light_mode_rounded;
      case TipoIncidente.pelea:             return Icons.sports_mma_rounded;
      case TipoIncidente.vandalismo:        return Icons.broken_image_rounded;
      case TipoIncidente.accidente:         return Icons.car_crash_rounded;
      case TipoIncidente.otro:              return Icons.more_horiz_rounded;
    }
  }

  IconData get mapIcon {
    switch (this) {
      case TipoIncidente.robo:              return Icons.no_backpack_rounded;
      case TipoIncidente.acoso:             return Icons.person_off_rounded;
      case TipoIncidente.personaSospechosa: return Icons.visibility_rounded;
      case TipoIncidente.iluminacion:       return Icons.flashlight_off_rounded;
      case TipoIncidente.pelea:             return Icons.sports_kabaddi_rounded;
      case TipoIncidente.vandalismo:        return Icons.broken_image_rounded;
      case TipoIncidente.accidente:         return Icons.car_crash_rounded;
      case TipoIncidente.otro:              return Icons.report_rounded;
    }
  }

  static TipoIncidente fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'robo':               return TipoIncidente.robo;
      case 'acoso':              return TipoIncidente.acoso;
      case 'persona sospechosa': return TipoIncidente.personaSospechosa;
      case 'iluminación':
      case 'iluminacion':        return TipoIncidente.iluminacion;
      case 'pelea':              return TipoIncidente.pelea;
      case 'vandalismo':         return TipoIncidente.vandalismo;
      case 'accidente':          return TipoIncidente.accidente;
      default:                   return TipoIncidente.otro;
    }
  }
}

class Reporte {
  final String id;
  final TipoIncidente tipo;
  final String descripcion;
  final NivelUrgencia nivelUrgencia;
  final double lat;
  final double lng;
  final String? userId;
  final int testigos;
  final String? fotoUrl;
  final DateTime? createdAt;

  const Reporte({
    required this.id,
    required this.tipo,
    required this.descripcion,
    required this.nivelUrgencia,
    required this.lat,
    required this.lng,
    this.userId,
    this.testigos = 0,
    this.fotoUrl,
    this.createdAt,
  });

  factory Reporte.fromMap(Map<String, dynamic> map) {
    return Reporte(
      id: map['id']?.toString() ?? '',
      tipo: TipoIncidenteX.fromString(map['tipo']?.toString()),
      descripcion: map['descripcion']?.toString() ?? '',
      nivelUrgencia: NivelUrgenciaX.fromString(map['nivel_urgencia']?.toString()),
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
      userId: map['user_id']?.toString() ?? map['usuario_id']?.toString(),
      testigos: (map['testigos'] as num?)?.toInt() ?? 0,
      fotoUrl: map['foto_url']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'tipo': tipo.label,
        'descripcion': descripcion,
        'nivel_urgencia': nivelUrgencia.label,
        'lat': lat,
        'lng': lng,
        if (userId != null) 'user_id': userId,
        'testigos': testigos,
        if (fotoUrl != null) 'foto_url': fotoUrl,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  String get tiempoTranscurrido {
    if (createdAt == null) return 'Hace un momento';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  bool perteneceA(String uid) => userId == uid;
}
