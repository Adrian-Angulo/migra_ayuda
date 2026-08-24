import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/widgets/legal/section_title.dart';

class PrivacyPolicyWidget extends StatelessWidget {
  const PrivacyPolicyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
          leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon:  const Icon(Icons.arrow_back_ios_new_rounded)),
        title: const Text(
              'Política de Privacidad',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),),
      body:  const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Última actualización: 24 de agosto de 2026',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
      
            SizedBox(height: 24),
      
            SectionTitle(
              title: '1. Información que recopilamos',
            ),
      
            Text(
              'MigraAyuda puede recopilar información necesaria para '
              'crear y administrar cuentas, proporcionar sus funcionalidades '
              'y mejorar la aplicación, como nombre, correo electrónico, '
              'información proporcionada por el usuario y, cuando sea '
              'autorizado, ubicación.',
            ),
      
            SizedBox(height: 20),
      
            SectionTitle(
              title: '2. Uso de la información',
            ),
      
            Text(
              'Los datos pueden utilizarse para gestionar cuentas, '
              'proporcionar funcionalidades, facilitar la búsqueda '
              'de servicios, mejorar la seguridad y atender solicitudes.',
            ),
      
            SizedBox(height: 20),
      
            SectionTitle(
              title: '3. Ubicación',
            ),
      
            Text(
              'La aplicación puede solicitar acceso a la ubicación '
              'del dispositivo para mostrar servicios y entidades cercanas. '
              'El usuario puede administrar este permiso desde la '
              'configuración de su dispositivo.',
            ),
      
            SizedBox(height: 20),
      
            SectionTitle(
              title: '4. Protección de los datos',
            ),
      
            Text(
              'MigraAyuda implementará medidas razonables para proteger '
              'la información personal contra accesos, pérdidas o usos '
              'no autorizados.',
            ),
      
            SizedBox(height: 20),
      
            SectionTitle(
              title: '5. Servicios de terceros',
            ),
      
            Text(
              'La aplicación puede utilizar servicios externos para funciones '
              'como autenticación, almacenamiento, mapas y ubicación. '
              'Estos servicios pueden tener sus propias políticas de privacidad.',
            ),
      
            SizedBox(height: 20),
      
            SectionTitle(
              title: '6. Derechos del usuario',
            ),
      
            Text(
              'El usuario puede solicitar información sobre sus datos '
              'personales, solicitar su actualización o corrección y '
              'ejercer los demás derechos reconocidos por la legislación '
              'colombiana aplicable.',
            ),
      
            SizedBox(height: 20),
      
            SectionTitle(
              title: '7. Cambios y contacto',
            ),
      
            Text(
              'Esta política puede actualizarse cuando sea necesario. '
              'Para realizar consultas o solicitudes relacionadas con '
              'los datos personales, el usuario podrá utilizar los '
              'canales oficiales de contacto de MigraAyuda.',
            ),
      
            SizedBox(height: 32),
      
            Text(
              'Al utilizar MigraAyuda, el usuario declara conocer '
              'esta Política de Privacidad.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

