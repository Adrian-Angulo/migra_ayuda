import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Error en el servidor', super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Error de conexión. Verifica tu acceso a internet.',
    super.code,
  });
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'Ocurrió un error inesperado',
    super.code,
  });
}
