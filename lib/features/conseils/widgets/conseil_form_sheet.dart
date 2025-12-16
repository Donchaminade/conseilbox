import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../core/models/conseil.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/conseil_service.dart';

class ConseilFormSheet extends StatefulWidget {
  const ConseilFormSheet({super.key, required this.service});
  final ConseilService service;

  @override
  State<ConseilFormSheet> createState() => _ConseilFormSheetState();
}

class _ConseilFormSheetState extends State<ConseilFormSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _anecdoteController = TextEditingController();
  final _authorController = TextEditingController();
  final _locationController = TextEditingController();
  final _social1Controller = TextEditingController();
  final _social2Controller = TextEditingController();
  final _social3Controller = TextEditingController();

  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _anecdoteController.dispose();
    _authorController.dispose();
    _locationController.dispose();
    _social1Controller.dispose();
    _social2Controller.dispose();
    _social3Controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final payload = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'anecdote': _anecdoteController.text.trim(),
        'author': _authorController.text.trim(),
        'location': _locationController.text.trim(),
        'social_link_1': _social1Controller.text.trim(),
        'social_link_2': _social2Controller.text.trim(),
        'social_link_3': _social3Controller.text.trim(),
      }..removeWhere((_, v) => v.isEmpty);

      final created = await widget.service.createConseil(payload);

      if (!mounted) return;
      Navigator.of(context).pop(created);
    } on ApiException catch (error) {
      setState(() {
        _error = error.details?.values.join('\n') ?? error.message;
      });
    } catch (_) {
      setState(() {
        _error = "Impossible d'envoyer votre conseil pour le moment.";
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Informations du conseil"),
                      _buildInput(
                        controller: _titleController,
                        label: "Titre du conseil",
                        prefix: Icons.title,
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                      _buildInput(
                        controller: _contentController,
                        label: "Contenu du conseil",
                        prefix: Icons.library_books,
                        maxLines: 5,
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      _buildInput(
                        controller: _anecdoteController,
                        label: "Anecdote ou contexte (optionnel)",
                        prefix: Icons.lightbulb_outline,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 28),
                      _sectionTitle("À propos de l'auteur"),
                      _buildInput(
                        controller: _authorController,
                        label: "Nom ou pseudonyme",
                        prefix: Icons.person_outline,
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                      _buildInput(
                        controller: _locationController,
                        label: "Localisation (ville, pays)",
                        prefix: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 28),
                      _sectionTitle("Liens sociaux (optionnels)"),
                      _buildInput(
                        controller: _social1Controller,
                        label: "Profil social #1",
                        prefix: Icons.link,
                        keyboard: TextInputType.url,
                      ),
                      const SizedBox(height: 14),
                      _buildInput(
                        controller: _social2Controller,
                        label: "Profil social #2",
                        prefix: Icons.link,
                        keyboard: TextInputType.url,
                      ),
                      const SizedBox(height: 14),
                      _buildInput(
                        controller: _social3Controller,
                        label: "Profil social #3",
                        prefix: Icons.link,
                        keyboard: TextInputType.url,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                      const SizedBox(height: 30),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical:
              44), // Padding du contenu du header (encore plus augmenté le vertical)
      decoration: const BoxDecoration(
        color: AppColors.chocolat,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Partager un  conseil",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  "Contribuez à la communauté.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0, // Ajusté pour ne plus remonter l'icône
            right: 0,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close),
              color: Colors.white, // Icône de fermeture blanche
              padding: const EdgeInsets.all(
                  0), // Supprimer le padding par défaut de l'IconButton
              constraints:
                  const BoxConstraints(), // Supprimer les contraintes de taille par défaut
            ),
          ),
        ],
      ),
    );
  }

  // INPUT CHIC
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData prefix,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(prefix, color: AppColors.chocolat.withOpacity(0.6)),
        filled: true,
        fillColor: const Color(0xFFFFF8F3), // crème doux
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        // Bordure par défaut (non focus, non erreur)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: AppColors.chocolat.withOpacity(0.4), width: 1.0),
        ),
        // Bordure quand le champ est focus
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.chocolat, width: 1.6),
        ),
        // Bordure quand il y a une erreur de validation
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.6),
        ),
        // Bordure quand il y a une erreur et que le champ est focus
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2.0),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 17,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submit,
        icon: _isSubmitting
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.check_circle_outline, color: Colors.white),
        label: Text(
          _isSubmitting ? "Envoi en cours..." : "Soumettre le conseil",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.chocolat,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 3,
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return "Champ requis";
    return null;
  }
}
