import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

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
      case NivelUrgencia.bajo:
        return 'bajo';
      case NivelUrgencia.medio:
        return 'medio';
      case NivelUrgencia.alto:
        return 'alto';
      case NivelUrgencia.critico:
        return 'critico';
    }
  }

  String get labelCapitalized => label[0].toUpperCase() + label.substring(1);

  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case NivelUrgencia.bajo:
        return l10n.lowRisk;
      case NivelUrgencia.medio:
        return l10n.mediumRisk;
      case NivelUrgencia.alto:
        return l10n.highRisk;
      case NivelUrgencia.critico:
        return l10n.criticalRisk;
    }
  }

  int get puntos {
    switch (this) {
      case NivelUrgencia.critico:
        return 10;
      case NivelUrgencia.alto:
        return 5;
      case NivelUrgencia.medio:
        return 2;
      case NivelUrgencia.bajo:
        return 1;
    }
  }

  static NivelUrgencia fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'critico':
      case 'crítico':
        return NivelUrgencia.critico;
      case 'alto':
        return NivelUrgencia.alto;
      case 'medio':
        return NivelUrgencia.medio;
      default:
        return NivelUrgencia.bajo;
    }
  }
}

extension TipoIncidenteX on TipoIncidente {
  String get key {
    switch (this) {
      case TipoIncidente.robo:
        return 'robo';
      case TipoIncidente.acoso:
        return 'acoso';
      case TipoIncidente.personaSospechosa:
        return 'persona_sospechosa';
      case TipoIncidente.iluminacion:
        return 'iluminacion';
      case TipoIncidente.pelea:
        return 'pelea';
      case TipoIncidente.vandalismo:
        return 'vandalismo';
      case TipoIncidente.accidente:
        return 'accidente';
      case TipoIncidente.otro:
        return 'otro';
    }
  }

  String get label {
    switch (this) {
      case TipoIncidente.robo:
        return 'Robo';
      case TipoIncidente.acoso:
        return 'Acoso';
      case TipoIncidente.personaSospechosa:
        return 'Persona sospechosa';
      case TipoIncidente.iluminacion:
        return 'Iluminación';
      case TipoIncidente.pelea:
        return 'Pelea';
      case TipoIncidente.vandalismo:
        return 'Vandalismo';
      case TipoIncidente.accidente:
        return 'Accidente';
      case TipoIncidente.otro:
        return 'Otro';
    }
  }

  String localizedLabel(AppLocalizations l10n, [String? raw]) {
    if (this != TipoIncidente.otro) {
      switch (this) {
        case TipoIncidente.robo: return l10n.incidentTheft;
        case TipoIncidente.acoso: return l10n.incidentHarassment;
        case TipoIncidente.personaSospechosa: return l10n.incidentSuspiciousPerson;
        case TipoIncidente.iluminacion: return l10n.incidentLighting;
        case TipoIncidente.pelea: return l10n.incidentFight;
        case TipoIncidente.vandalismo: return l10n.incidentVandalism;
        case TipoIncidente.accidente: return l10n.incidentAccident;
        default: return l10n.incidentOther;
      }
    }
    return raw ?? l10n.incidentOther;
  }

  IconData getIcon(String? raw) {
    if (this != TipoIncidente.otro) {
      switch (this) {
        case TipoIncidente.robo: return Icons.phone_android_rounded;
        case TipoIncidente.acoso: return Icons.warning_rounded;
        case TipoIncidente.personaSospechosa: return Icons.person_off_rounded;
        case TipoIncidente.iluminacion: return Icons.light_mode_rounded;
        case TipoIncidente.pelea: return Icons.sports_mma_rounded;
        case TipoIncidente.vandalismo: return Icons.broken_image_rounded;
        case TipoIncidente.accidente: return Icons.car_crash_rounded;
        default: return Icons.more_horiz_rounded;
      }
    }
    final n = raw?.toLowerCase() ?? '';
    if (n.contains('robo')) return Icons.phone_android_rounded;
    if (n.contains('acoso')) return Icons.warning_rounded;
    if (n.contains('pelea')) return Icons.sports_mma_rounded;
    return Icons.more_horiz_rounded;
  }

  IconData getMapIcon(String? raw) {
    if (this != TipoIncidente.otro) {
      switch (this) {
        case TipoIncidente.robo: return Icons.no_backpack_rounded;
        case TipoIncidente.acoso: return Icons.person_off_rounded;
        case TipoIncidente.personaSospechosa: return Icons.visibility_rounded;
        case TipoIncidente.iluminacion: return Icons.flashlight_off_rounded;
        case TipoIncidente.pelea: return Icons.sports_kabaddi_rounded;
        case TipoIncidente.vandalismo: return Icons.broken_image_rounded;
        case TipoIncidente.accidente: return Icons.car_crash_rounded;
        default: return Icons.report_rounded;
      }
    }
    return Icons.report_rounded;
  }

  static TipoIncidente fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'robo':
        return TipoIncidente.robo;
      case 'acoso':
        return TipoIncidente.acoso;
      case 'persona sospechosa':
        return TipoIncidente.personaSospechosa;
      case 'iluminación':
      case 'iluminacion':
        return TipoIncidente.iluminacion;
      case 'pelea':
        return TipoIncidente.pelea;
      case 'vandalismo':
        return TipoIncidente.vandalismo;
      case 'accidente':
        return TipoIncidente.accidente;
      default:
        return TipoIncidente.otro;
    }
  }
}

class Reporte {
  final String id;
  final TipoIncidente tipo;
  final String tipoRaw;
  final String descripcion;
  final NivelUrgencia nivelUrgencia;
  final double lat;
  final double lng;
  final String? userId;
  final int testigos;
  final int votosPositivos;
  final int votosNegativos;
  final String? fotoUrl;
  final DateTime? createdAt;
  final String? userName;
  final String? userLastName;
  final String? userFotoUrl;

  const Reporte({
    required this.id,
    required this.tipo,
    required this.tipoRaw,
    required this.descripcion,
    required this.nivelUrgencia,
    required this.lat,
    required this.lng,
    this.userId,
    this.testigos = 0,
    this.votosPositivos = 0,
    this.votosNegativos = 0,
    this.fotoUrl,
    this.createdAt,
    this.userName,
    this.userLastName,
    this.userFotoUrl,
  });

  factory Reporte.fromMap(Map<String, dynamic> map) {
    final rawType = map['tipo']?.toString() ?? 'Otro';
    return Reporte(
      id: map['id']?.toString() ?? '',
      tipo: TipoIncidenteX.fromString(rawType),
      tipoRaw: rawType,
      descripcion: map['descripcion']?.toString() ?? '',
      nivelUrgencia:
          NivelUrgenciaX.fromString(map['nivel_urgencia']?.toString()),
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
      userId: map['user_id']?.toString() ?? map['usuario_id']?.toString(),
      testigos: (map['testigos'] as num?)?.toInt() ?? 0,
      votosPositivos: (map['votos_positivos'] as num?)?.toInt() ?? 0,
      votosNegativos: (map['votos_negativos'] as num?)?.toInt() ?? 0,
      fotoUrl: map['foto_url']?.toString(),
      createdAt: map['created_at'] != null
          ? (map['created_at'] is DateTime 
              ? map['created_at'] as DateTime 
              : DateTime.tryParse(map['created_at'].toString()))
          : null,
      userName: map['usuario_nombre']?.toString() ?? 'Anónimo',
      userLastName: map['usuario_apellido']?.toString() ?? '',
      userFotoUrl: map['usuario_foto_url']?.toString(),
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
        'votos_positivos': votosPositivos,
        'votos_negativos': votosNegativos,
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

  String localizedTiempoTranscurrido(AppLocalizations l10n) {
    if (createdAt == null) return l10n.timeAgoNow;
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return l10n.timeAgoNow;
    if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
    if (diff.inDays < 7) return l10n.timeAgoDays(diff.inDays);
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  String localizedFechaHora(AppLocalizations l10n) {
    if (createdAt == null) return l10n.timeAgoNow;
    final h = createdAt!.hour.toString().padLeft(2, '0');
    final m = createdAt!.minute.toString().padLeft(2, '0');
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year} $h:$m';
  }

  bool perteneceA(String uid) => userId == uid;
}
