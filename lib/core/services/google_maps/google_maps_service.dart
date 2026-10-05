// Función básica para iniciar la navegación
import 'package:url_launcher/url_launcher.dart';

class GoogleMapsNavigationService {
  GoogleMapsNavigationService();

  Future<void> startNavigation(double latitud, double longitud) async {
    try {
      
      final String googleMapsUrl =
          'geo:$latitud,$longitud?q=$latitud,$longitud&travelmode=walking';
      final Uri uri = Uri.parse(googleMapsUrl);

      
      if (await canLaunchUrl(uri)) {
     
        await launchUrl(uri);
      } else {
     
        final String webUrl =
            'https://www.google.com/maps/search/?api=1&query=$latitud,$longitud';
        await launchUrl(Uri.parse(webUrl),
            mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      throw Exception('No se pudo iniciar la navegación: $e');
    }
  }
}
