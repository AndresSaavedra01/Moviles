
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/universidad_fb.dart';
import '../../services/universidad_service.dart';

class UniversidadFbFormView extends StatefulWidget {
  final String? id;

  const UniversidadFbFormView({super.key, this.id});

  @override
  State<UniversidadFbFormView> createState() => _UniversidadFbFormViewState();
}

class _UniversidadFbFormViewState extends State<UniversidadFbFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nitController = TextEditingController();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _paginaWebController = TextEditingController();

  bool _camposInicializados = false;

  Future<void> _guardar({String? id}) async {
    if (_formKey.currentState!.validate()) {
      try {
        final universidad = UniversidadFb(
          id: id ?? '',
          nit: _nitController.text.trim(),
          nombre: _nombreController.text.trim(),
          direccion: _direccionController.text.trim(),
          telefono: _telefonoController.text.trim(),
          paginaWeb: _paginaWebController.text.trim(),
        );

        if (widget.id == null) {
          await UniversidadService.addUniversidad(universidad);
        } else {
          await UniversidadService.updateUniversidad(universidad);
        }

        if (mounted) {
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.id == null
                    ? 'Universidad creada exitosamente'
                    : 'Universidad actualizada exitosamente',
              ),
              backgroundColor: colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: $e'),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _inicializarCampos(UniversidadFb universidad) {
    if (_camposInicializados) return;
    _nitController.text = universidad.nit;
    _nombreController.text = universidad.nombre;
    _direccionController.text = universidad.direccion;
    _telefonoController.text = universidad.telefono;
    _paginaWebController.text = universidad.paginaWeb;
    _camposInicializados = true;
  }

  @override
  void dispose() {
    _nitController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _paginaWebController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool esNuevo = widget.id == null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(esNuevo ? 'Registrar Universidad' : 'Editar Universidad'),
      ),
      body: esNuevo
          ? _buildFormulario(context, id: null)
          : StreamBuilder<UniversidadFb?>(
        stream: UniversidadService.watchUniversidadById(widget.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorView(colorScheme, snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _buildNotFoundView(colorScheme);
          }

          final universidad = snapshot.data!;
          _inicializarCampos(universidad);
          return _buildFormulario(context, id: universidad.id);
        },
      ),
    );
  }

  Widget _buildErrorView(ColorScheme colorScheme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error al cargar universidad',
            style: TextStyle(fontSize: 18, color: colorScheme.error, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton.tonal(onPressed: () => context.pop(), child: const Text('Volver')),
        ],
      ),
    );
  }

  Widget _buildNotFoundView(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.domain_disabled_outlined, size: 60, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Universidad no encontrada', style: TextStyle(fontSize: 18, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          FilledButton.tonal(onPressed: () => context.pop(), child: const Text('Volver')),
        ],
      ),
    );
  }

  Widget _buildFormulario(BuildContext context, {required String? id}) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = screenWidth > 1200 ? 800 : screenWidth > 800 ? 600 : double.infinity;
    final double padding = screenWidth > 600 ? 24 : 16;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Información de la Institución', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.primary)),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _nitController,
                          decoration: _inputDecoration('NIT', 'Ej: 890.123.456-7', Icons.numbers),
                          validator: (value) => value!.trim().isEmpty ? 'El NIT es requerido' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _nombreController,
                          decoration: _inputDecoration('Nombre', 'Ej: UCEVA', Icons.account_balance),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) => value!.trim().isEmpty ? 'El nombre es requerido' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _direccionController,
                          decoration: _inputDecoration('Dirección', 'Ej: Cra 27A #48-144, Tuluá - Valle', Icons.location_on),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) => value!.trim().isEmpty ? 'La dirección es requerida' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _telefonoController,
                          decoration: _inputDecoration('Teléfono', 'Ej: +57 602 2242202', Icons.phone),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value!.trim().isEmpty ? 'El teléfono es requerido' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _paginaWebController,
                          decoration: _inputDecoration('Página Web', 'Ej: https://www.uceva.edu.co', Icons.language),
                          keyboardType: TextInputType.url,
                          validator: (value) => value!.trim().isEmpty ? 'La página web es requerida' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () => _guardar(id: id),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Guardar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}