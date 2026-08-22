import 'package:csv/csv.dart';
import 'package:migra_ayuda/core/services/export/csv_web_downloader_stub.dart'
    if (dart.library.js_interop) 'package:migra_ayuda/core/services/export/csv_web_downloader_web.dart';
import 'package:migra_ayuda/core/utils/format/time_formatter.dart';
import 'package:migra_ayuda/core/utils/utils.dart';
import 'package:migra_ayuda/features/audit/domain/entities/audit_entity.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';

class ExportService {
  static final _csv = Csv(fieldDelimiter: ';');

  /// Descarga un CSV en el navegador a partir de encabezados y filas.
  static void exportCsv({
    required String fileName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) {
    final csv = _csv.encode([headers, ...rows]);
    downloadCsvFile(csv, fileName);
  }

  static void exportUsers(List<Migrant> users) {
    exportCsv(
      fileName: 'usuarios',
      headers: const [
        'Nombre',
        'Correo',
        'Rol',
        'Edad',
        'País de origen',
        'País de destino',
        'Fecha de registro',
      ],
      rows: users
          .map(
            (user) => [
              user.name,
              user.email,
              user.role,
              user.age,
              user.originCountry,
              user.destinationCountry,
              TimeFormatter.formatShortDate(user.createdAt),
            ],
          )
          .toList(),
    );
  }

  static void exportEntities(List<EntityEntity> entities) {
    exportCsv(
      fileName: 'entidades',
      headers: const [
        'Nombre',
        'Dirección',
        'Teléfono',
        'Servicios',
        'Horario',
        'Descripción',
      ],
      rows: entities
          .map(
            (entity) => [
              entity.name,
              entity.address,
              entity.phone,
              entity.services.join(', '),
              entity.schedule,
              entity.description,
            ],
          )
          .toList(),
    );
  }

  static void exportActivities(List<AuditEntity> activities) {
    exportCsv(
      fileName: 'actividades',
      headers: const [
        'Nombre',
        'Correo',
        'País',
        'Acción',
        'Detalle',
        'Fecha',
      ],
      rows: activities
          .map(
            (activity) => [
              activity.nombre,
              activity.correo,
              activity.pais,
              activity.accion,
              Utils.formatMetadata(activity.metadata),
              TimeFormatter.formatShortDate(activity.createdAt),
            ],
          )
          .toList(),
    );
  }

  static void exportReviews(List<ReviewEntity> reviews) {
    exportCsv(
      fileName: 'resenas',
      headers: const [
        'Entidad',
        'Usuario',
        'País',
        'Valoración',
        'Comentario',
        'Fecha',
      ],
      rows: reviews
          .map(
            (review) => [
              review.nameEntity,
              review.userName,
              review.userCountry,
              review.rating.toStringAsFixed(1),
              review.comment,
              TimeFormatter.formatShortDate(review.createdAt),
            ],
          )
          .toList(),
    );
  }

}
