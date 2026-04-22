import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';

class EditarPerfilScreen extends ConsumerStatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  ConsumerState<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends ConsumerState<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _telefonoController;
  String? _photoPath;
  final _picker = ImagePicker();
  bool _isSaving = false;

  static const _photoKey = 'profile_photo_path';

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).usuario;
    _nombreController = TextEditingController(text: user?.nombre ?? '');
    _apellidoController = TextEditingController(text: user?.apellido ?? '');
    _telefonoController = TextEditingController(text: user?.telefono ?? '');
    _loadPhoto();
  }

  void _loadPhoto() {
    final path = Hive.box('settings').get(_photoKey) as String?;
    if (path != null && File(path).existsSync()) {
      setState(() => _photoPath = path);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file != null) {
      setState(() => _photoPath = file.path);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // 1. Guardar foto localmente (simulado)
      if (_photoPath != null) {
        await Hive.box('settings').put(_photoKey, _photoPath);
      } else {
        await Hive.box('settings').delete(_photoKey);
      }

      // 2. Actualizar datos en el backend (simulado vía authProvider si tuviera el método)
      // Por ahora actualizamos el estado local del usuario
      final currentUser = ref.read(authProvider).usuario;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          nombre: _nombreController.text.trim(),
          apellido: _apellidoController.text.trim(),
          telefono: _telefonoController.text.trim(),
        );
        // Aquí deberías llamar a un método de tu authProvider para persistir esto
        // ref.read(authProvider.notifier).updateUser(updatedUser);
      }

      if (mounted) {
        final currentL10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(currentL10n.profileUpdated),
            backgroundColor: AppColors.riskLow,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.riskHigh,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.saveButton,
                    style: const TextStyle(
                        color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPhotoSection(l10n),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _nombreController,
                label: l10n.firstName,
                icon: Icons.person_outline_rounded,
                validator: (v) => v!.isEmpty ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _apellidoController,
                label: l10n.lastName,
                icon: Icons.person_outline_rounded,
                validator: (v) => v!.isEmpty ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _telefonoController,
                label: l10n.phone,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(l10n.saveChanges,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(AppLocalizations l10n) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.5), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: _photoPath != null
                    ? Image.file(File(_photoPath!), fit: BoxFit.cover)
                    : Container(
                        color: Theme.of(context).cardColor,
                        child: const Icon(Icons.person_rounded,
                            size: 60, color: AppColors.textSecondary),
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showPhotoOptions(l10n),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded,
                      size: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _showPhotoOptions(l10n),
          child: Text(l10n.changeProfilePhoto,
              style: const TextStyle(color: AppColors.accent, fontSize: 14)),
        ),
      ],
    );
  }

  void _showPhotoOptions(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            _photoOptionTile(Icons.camera_alt_rounded, l10n.camera, () {
              Navigator.pop(ctx);
              _pickPhoto(ImageSource.camera);
            }),
            _photoOptionTile(Icons.photo_library_rounded, l10n.gallery, () {
              Navigator.pop(ctx);
              _pickPhoto(ImageSource.gallery);
            }),
            if (_photoPath != null)
              _photoOptionTile(Icons.delete_outline_rounded, l10n.deletePhoto,
                  () {
                Navigator.pop(ctx);
                setState(() => _photoPath = null);
              }, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _photoOptionTile(IconData icon, String label, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon,
          color: isDestructive ? AppColors.riskHigh : AppColors.accent),
      title: Text(label,
          style: TextStyle(
              color: isDestructive ? AppColors.riskHigh : null,
              fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppColors.accent),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
