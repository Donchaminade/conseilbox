import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import '../../../core/models/conseil.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/conseil_service.dart';

class ConseilFormSheet extends StatefulWidget {
  const ConseilFormSheet({
    super.key,
    required this.service,
  });

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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final Map<String, String> payload = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'anecdote': _anecdoteController.text.trim(),
        'author': _authorController.text.trim(),
        'location': _locationController.text.trim(),
        'social_link_1': _social1Controller.text.trim(),
        'social_link_2': _social2Controller.text.trim(),
        'social_link_3': _social3Controller.text.trim(),
      }..removeWhere((_, value) => value.isEmpty);

      final Conseil created = await widget.service.createConseil(payload);

      if (!mounted) return;
      Navigator.of(context).pop(created);
    } on ApiException catch (error) {
      setState(() {
        _error = error.details?.values.join('\n') ?? error.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Impossible d\'envoyer votre conseil pour le moment.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Partager un nouveau conseil',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _titleController,
                  label: 'Titre',
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _contentController,
                  label: 'Contenu',
                  maxLines: 4,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _anecdoteController,
                  label: 'Anecdote (optionnel)',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _authorController,
                  label: 'Auteur',
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _locationController,
                  label: 'Localisation',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _social1Controller,
                  label: 'Lien social #1',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _social2Controller,
                  label: 'Lien social #2',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _social3Controller,
                  label: 'Lien social #3',
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      _isSubmitting ? 'Envoi...' : 'Soumettre',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cafe,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Champ requis';
    }
    return null;
  }
}
