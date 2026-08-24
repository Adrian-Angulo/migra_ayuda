import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/widgets/legal/section_title.dart';

class TermsAndConditionsWidget extends StatelessWidget {
  const TermsAndConditionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon:  const Icon(Icons.arrow_back_ios_new_rounded)),
        title: const Text(
                'Términos y Condiciones',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),),
      body: const  SafeArea(
        child: SingleChildScrollView(
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
                title: '1. Uso de la aplicación',
              ),
        
              Text(
                'MigraAyuda es una aplicación destinada a facilitar '
                'el acceso a información sobre entidades, servicios '
                'y recursos de apoyo para personas migrantes.',
              ),
        
              SizedBox(height: 20),
        
              SectionTitle(
                title: '2. Cuenta de usuario',
              ),
        
              Text(
                'El usuario debe proporcionar información verdadera '
                'y mantener la seguridad de sus credenciales. No está '
                'permitido utilizar cuentas de otras personas.',
              ),
        
              SizedBox(height: 20),
        
              SectionTitle(
                title: '3. Información de servicios',
              ),
        
              Text(
                'La información sobre entidades, direcciones, horarios, '
                'servicios y contactos tiene carácter orientativo y puede cambiar.',
              ),
        
              SizedBox(height: 20),
        
              SectionTitle(
                title: '4. Uso indebido',
              ),
        
              Text(
                'Está prohibido utilizar MigraAyuda para actividades '
                'ilegales, fraudulentas o que afecten el funcionamiento '
                'y seguridad de la aplicación.',
              ),
        
              SizedBox(height: 20),
        
              SectionTitle(
                title: '5. Disponibilidad',
              ),
        
              Text(
                'MigraAyuda procura mantener sus servicios disponibles, '
                'pero pueden presentarse interrupciones por mantenimiento, '
                'problemas técnicos o conectividad.',
              ),
        
              SizedBox(height: 20),
        
              SectionTitle(
                title: '6. Privacidad',
              ),
        
              Text(
                'El tratamiento de los datos personales se realizará '
                'de acuerdo con nuestra Política de Privacidad y la '
                'legislación colombiana aplicable.',
              ),
        
              SizedBox(height: 20),
        
              SectionTitle(
                title: '7. Modificaciones',
              ),
        
              Text(
                'Estos términos podrán actualizarse cuando sea necesario. '
                'La versión vigente estará disponible en los canales oficiales '
                'de MigraAyuda.',
              ),
        
              SizedBox(height: 20),
        
              SectionTitle(
                title: '8. Contacto',
              ),
        
              Text(
                'Para preguntas o solicitudes relacionadas con estos términos, '
                'el usuario podrá comunicarse mediante los canales oficiales '
                'de MigraAyuda.',
              ),
        
              SizedBox(height: 32),
        
              Text(
                'Al utilizar la aplicación, el usuario acepta estos '
                'Términos y Condiciones.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
