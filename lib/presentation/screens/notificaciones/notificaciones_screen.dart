import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final List<_Notificacion> _notificaciones = [
    _Notificacion(
      tipo: _TipoNotif.alerta,
      titulo: 'Alerta de seguridad cercana',
      cuerpo: 'Se reportó un robo a 200m de tu ubicación actual. Mantente alerta.',
      hora: 'Hace 5 min',
      leida: false,
    ),
    _Notificacion(
      tipo: _TipoNotif.reporte,
      titulo: 'Nuevo reporte en el campus',
      cuerpo: 'Pelea reportada cerca del edificio de Ingeniería.',
      hora: 'Hace 18 min',
      leida: false,
    ),
    _Notificacion(
      tipo: _TipoNotif.ia,
      titulo: 'SafeBot — Análisis completado',
      cuerpo: 'Tu zona tiene nivel de riesgo medio en las últimas 2 horas. Recomendamos evitar el parqueadero norte.',
      hora: 'Hace 1 h',
      leida: false,
    ),
    _Notificacion(
      tipo: _TipoNotif.sistema,
      titulo: 'Reporte enviado exitosamente',
      cuerpo: 'Tu reporte de "Persona sospechosa" fue recibido y está siendo revisado.',
      hora: 'Hace 3 h',
      leida: true,
    ),
    _Notificacion(
      tipo: _TipoNotif.alerta,
      titulo: 'Zona de riesgo actualizada',
      cuerpo: 'El sector de la biblioteca ha bajado su nivel de riesgo a bajo.',
      hora: 'Hace 5 h',
      leida: true,
    ),
    _Notificacion(
      tipo: _TipoNotif.ia,
      titulo: 'Ruta segura disponible',
      cuerpo: 'SafeBot calculó una ruta alternativa más segura hacia el edificio C.',
      hora: 'Ayer',
      leida: true,
    ),
    _Notificacion(
      tipo: _TipoNotif.sistema,
      titulo: 'Bienvenido a SafeCampus AI',
      cuerpo: 'Tu cuenta ha sido verificada. Ya puedes reportar incidentes y recibir alertas en tiempo real.',
      hora: 'Hace 2 días',
      leida: true,
    ),
  ];

  int get _noLeidas => _notificaciones.where((n) => !n.leida).length;

  void _marcarTodasLeidas() {
    setState(() {
      for (final n in _notificaciones) {
        n.leida = true;
      }
    });
  }

  void _marcarLeida(int index) {
    setState(() => _notificaciones[index].leida = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _notificaciones.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      itemCount: _notificaciones.length,
                      itemBuilder: (context, i) => FadeInUp(
                        delay: Duration(milliseconds: i * 40),
                        child: _NotifCard(
                          notif: _notificaciones[i],
                          onTap: () => _marcarLeida(i),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notificaciones',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              if (_noLeidas > 0)
                Text('$_noLeidas sin leer',
                    style: const TextStyle(
                        color: AppColors.accent, fontSize: 12)),
            ],
          ),
          const Spacer(),
          if (_noLeidas > 0)
            TextButton(
              onPressed: _marcarTodasLeidas,
              child: const Text('Leer todas',
                  style: TextStyle(color: AppColors.accent, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _EmptyIcon(),
          SizedBox(height: 16),
          Text('Sin notificaciones',
              style: TextStyle(color: Colors.white54, fontSize: 16)),
          SizedBox(height: 6),
          Text('Te avisaremos cuando haya alertas en el campus',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white30, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Modelo ────────────────────────────────────────────────────────────────────

enum _TipoNotif { alerta, reporte, ia, sistema }

class _Notificacion {
  final _TipoNotif tipo;
  final String titulo;
  final String cuerpo;
  final String hora;
  bool leida;

  _Notificacion({
    required this.tipo,
    required this.titulo,
    required this.cuerpo,
    required this.hora,
    required this.leida,
  });
}

// ── Empty icon ────────────────────────────────────────────────────────────────

class _EmptyIcon extends StatelessWidget {
  const _EmptyIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.cardColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.notifications_off_outlined,
          color: Colors.white24, size: 48),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final _Notificacion notif;
  final VoidCallback onTap;

  const _NotifCard({required this.notif, required this.onTap});

  Color get _color {
    switch (notif.tipo) {
      case _TipoNotif.alerta:   return AppColors.riskHigh;
      case _TipoNotif.reporte:  return AppColors.riskMedium;
      case _TipoNotif.ia:       return AppColors.accent;
      case _TipoNotif.sistema:  return AppColors.riskLow;
    }
  }

  IconData get _icon {
    switch (notif.tipo) {
      case _TipoNotif.alerta:   return Icons.warning_amber_rounded;
      case _TipoNotif.reporte:  return Icons.report_rounded;
      case _TipoNotif.ia:       return Icons.psychology_rounded;
      case _TipoNotif.sistema:  return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.leida
              ? AppColors.cardColor
              : _color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.leida ? Colors.white12 : _color.withValues(alpha: 0.35),
            width: notif.leida ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.titulo,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: notif.leida
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!notif.leida)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 2),
                          decoration: BoxDecoration(
                            color: _color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.cuerpo,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(notif.hora,
                      style: const TextStyle(
                          color: Colors.white30, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
