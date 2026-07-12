import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/providers.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/register_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/widgets/input_field_web.dart';

class RegisterAdminDialog extends ConsumerStatefulWidget {
  const RegisterAdminDialog({super.key});

  @override
  ConsumerState<RegisterAdminDialog> createState() =>
      _RegisterAdminDialogState();
}

class _RegisterAdminDialogState extends ConsumerState<RegisterAdminDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final registerState = ref.watch(registerProvider);

    // ✅ Escuchar cambios de estado
    ref.listen(
      registerProvider,
      (previous, next) {
        // Solo reaccionar si el estado anterior era loading
        if (previous?.isLoading == true) {
          next.when(
            data: (success) {
              if (success == true) {
                // ✅ Registro exitoso
                ref.read(usersNotifierProvider.notifier).refresh();
                context.pop(); // Cerrar el diálogo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('✅ Usuario administrador registrado exitosamente'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            error: (error, stack) {
              // ❌ Error en el registro
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Error: $error'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            },
            loading: () {
              // No hacer nada mientras carga
            },
          );
        }
      },
    );

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.admin_panel_settings_outlined,
                        color: colors.primary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registrar Administrador',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Completa la información para crear un nuevo administrador.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),

                const SizedBox(height: 28),

                Divider(color: Colors.grey.shade300),

                const SizedBox(height: 24),

                InputFieldWeb(
                  label: 'Nombre',
                  hint: 'Ej. Carlos Mario',
                  icon: Icons.person_outline,
                  controller: _nameController,
                ),

                const SizedBox(height: 20),

                InputFieldWeb(
                  label: 'Correo',
                  hint: 'carlos@email.com',
                  icon: Icons.mail_outline,
                  controller: _emailController,
                ),

                const SizedBox(height: 20),

                InputFieldWeb(
                  controller: _passwordController,
                  label: 'Contraseña',
                  hint: 'Mínimo 8 caracteres',
                  icon: Icons.lock_outline,
                  obscureText: obscurePassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Utiliza una contraseña segura combinando letras, números y símbolos.',
                          style: TextStyle(height: 1.4),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                if (registerState.hasError)
                  Text(registerState.error.toString()),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: registerState.isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(180, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: registerState.isLoading
                          ? null
                          : () async {
                              if (_formkey.currentState?.validate() ?? false) {
                                await ref
                                    .read(registerProvider.notifier)
                                    .registerUser(UserModel(
                                      name: _nameController.text.trim(),
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim(),
                                      role: 'Admin',
                                    ));
                              }
                            },
                      child: registerState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Registrar',
                              style: TextStyle(fontSize: 16),
                            ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
