import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/contacto_emergencia.dart';
import '../../../core/providers/emergency_contacts_provider.dart';

class ContactosEmergenciaScreen extends ConsumerStatefulWidget {
  const ContactosEmergenciaScreen({super.key});

  @override
  ConsumerState<ContactosEmergenciaScreen> createState() =>
      _ContactosEmergenciaScreenState();
}

class _ContactosEmergenciaScreenState
    extends ConsumerState<ContactosEmergenciaScreen> {
  void _agregar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AgregarContactoSheet(
        onGuardar: (c) {
          ref.read(emergencyContactsProvider.notifier).addContact(c);
        },
      ),
    );
  }

  void _eliminar(ContactoEmergencia contacto) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: const Text('Eliminar contacto',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar a ${contacto.nombre}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              ref.read(emergencyContactsProvider.notifier).removeContact(contacto.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.riskHigh)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsState = ref.watch(emergencyContactsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(contactsState.contacts.length),
            const SizedBox(height: 12),
            _buildInfoBanner(),
            Expanded(
              child: contactsState.contacts.isEmpty
                  ? _buildEmpty()
                  : _buildLista(contactsState.contacts),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregar,
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Agregar',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(int count) {
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
              const Text('Contactos de Emergencia',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(
                '$count / 5 contactos',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline_rounded,
                color: AppColors.accent, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Al activar SOS, estos contactos recibirán tu ubicación y una alerta inmediata.',
                style:
                    TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.group_add_rounded,
                color: Colors.white24, size: 52),
          ),
          const SizedBox(height: 18),
          const Text('Sin contactos de emergencia',
              style: TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Agrega personas de confianza\npara alertarlas automáticamente',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(List<ContactoEmergencia> contacts) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: contacts.length,
      itemBuilder: (ctx, i) => FadeInUp(
        delay: Duration(milliseconds: i * 50),
        child: _ContactoCard(
          contacto: contacts[i],
          onEliminar: () => _eliminar(contacts[i]),
        ),
      ),
    );
  }
}

// ── Modelo local removido (usamos ContactoEmergencia del core) ──────────────

// ── Card de contacto ──────────────────────────────────────────────────────────

class _ContactoCard extends StatelessWidget {
  final ContactoEmergencia contacto;
  final VoidCallback onEliminar;

  const _ContactoCard({required this.contacto, required this.onEliminar});

  static const _colores = [
    AppColors.accent,
    AppColors.riskMedium,
    AppColors.riskLow,
    AppColors.primary,
    AppColors.riskHigh,
  ];

  Color get _color =>
      _colores[contacto.nombre.codeUnitAt(0) % _colores.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: _color.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(contacto.iniciales,
                  style: TextStyle(
                      color: _color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contacto.nombre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(contacto.telefono,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 2),
                if (contacto.relacion != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(contacto.relacion!,
                        style: TextStyle(
                            color: _color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.riskHigh, size: 22),
                onPressed: onEliminar,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sheet agregar contacto ────────────────────────────────────────────────────

class _AgregarContactoSheet extends StatefulWidget {
  final void Function(ContactoEmergencia) onGuardar;

  const _AgregarContactoSheet({required this.onGuardar});

  @override
  State<_AgregarContactoSheet> createState() =>
      _AgregarContactoSheetState();
}

class _AgregarContactoSheetState extends State<_AgregarContactoSheet> {
  final _nombreCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  String _relacion = 'Familiar';

  static const _relaciones = [
    'Familiar', 'Amigo/a', 'Pareja', 'Compañero/a', 'Otro'
  ];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_nombreCtrl.text.trim().isEmpty || _telCtrl.text.trim().isEmpty) return;
    widget.onGuardar(ContactoEmergencia(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nombreCtrl.text.trim(),
      telefono: _telCtrl.text.trim(),
      relacion: _relacion,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Agregar Contacto',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _field(_nombreCtrl, 'Nombre completo', Icons.person_outline_rounded),
          const SizedBox(height: 12),
          _field(_telCtrl, 'Teléfono', Icons.phone_outlined,
              type: TextInputType.phone),
          const SizedBox(height: 16),
          const Text('Relación',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _relaciones.map((r) {
              final sel = _relacion == r;
              return ChoiceChip(
                label: Text(r),
                selected: sel,
                onSelected: (_) => setState(() => _relacion = r),
                selectedColor: AppColors.accent.withValues(alpha: 0.25),
                backgroundColor: AppColors.cardColor,
                labelStyle: TextStyle(
                    color: sel ? AppColors.accent : Colors.white54,
                    fontSize: 12),
                side: BorderSide(
                    color: sel
                        ? AppColors.accent
                        : Colors.white12),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Guardar',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: AppColors.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}
