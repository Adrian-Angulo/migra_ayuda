import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/constants/app_constants.dart';
import 'package:migra_ayuda/core/router/routes.dart';

class PrivacyPolicyWebScreen extends StatelessWidget {
  const PrivacyPolicyWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'MigraAyuda - Política de Privacidad',
          style: TextStyle(
            color: ColorConstants.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorConstants.primary),
          tooltip: 'Volver',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.login);
            }
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            children: [
              Card(
                elevation: UIConstants.elevationLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusL),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Política de Privacidad',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Última actualización: 24 de agosto de 2026',
                        style: TextStyle(color: ColorConstants.grey600),
                      ),
                      Divider(height: 32),
                      _Section(
                        title: '1. Información que recopilamos',
                        content:
                            'MigraAyuda puede recopilar información necesaria para crear y administrar cuentas, proporcionar sus funcionalidades y mejorar la aplicación, como nombre, correo electrónico, información proporcionada por el usuario y, cuando sea autorizado, ubicación.',
                      ),
                      _Section(
                        title: '2. Uso de la información',
                        content:
                            'Los datos pueden utilizarse para gestionar cuentas, proporcionar funcionalidades, facilitar la búsqueda de servicios, mejorar la seguridad y atender solicitudes.',
                      ),
                      _Section(
                        title: '3. Ubicación',
                        content:
                            'La aplicación puede solicitar acceso a la ubicación del dispositivo para mostrar servicios y entidades cercanas. El usuario puede administrar este permiso desde la configuración de su dispositivo.',
                      ),
                      _Section(
                        title: '4. Protección de los datos',
                        content:
                            'MigraAyuda implementará medidas razonables para proteger la información personal contra accesos, pérdidas o usos no autorizados.',
                      ),
                      _Section(
                        title: '5. Servicios de terceros',
                        content:
                            'La aplicación puede utilizar servicios externos para funciones como autenticación, almacenamiento, mapas y ubicación. Estos servicios pueden tener sus propias políticas de privacidad.',
                      ),
                      _Section(
                        title: '6. Derechos del usuario',
                        content:
                            'El usuario puede solicitar información sobre sus datos personales, solicitar su actualización o corrección y ejercer los demás derechos reconocidos por la legislación aplicable.',
                      ),
                      _Section(
                        title: '7. Cambios y contacto',
                        content:
                            'Esta política puede actualizarse cuando sea necesario. Para realizar consultas o solicitudes relacionadas con los datos personales, el usuario podrá utilizar los canales oficiales de contacto de MigraAyuda.',
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Al utilizar MigraAyuda, el usuario declara conocer esta Política de Privacidad.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorConstants.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: ColorConstants.grey800,
            ),
          ),
        ],
      ),
    );
  }
}
