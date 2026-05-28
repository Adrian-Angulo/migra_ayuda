// Función básica para iniciar la navegación
  import 'package:url_launcher/url_launcher.dart';

Future<void> abrirNavegacionGoogleMaps(double latitud, double longitud) async {
    // Creamos el enlace especial de navegación de Google Maps
    final String googleMapsUrl = 'google.navigation:q=$latitud,$longitud';
    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      // 1. Verificamos si el teléfono puede abrir este tipo de enlace
      if (await canLaunchUrl(uri)) {
        // 2. Abrimos la aplicación de Google Maps externa
        await launchUrl(uri);
      } else {
        // Si no puede abrir la app nativa (ej. en un emulador), podemos abrir el navegador web como alternativa
        final String webUrl = 'https://www.google.com/maps/search/?api=1&query=$latitud,$longitud';
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('No se pudo abrir la aplicación de mapas: $e');
    }
  }