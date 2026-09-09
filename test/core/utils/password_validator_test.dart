import 'package:flutter_test/flutter_test.dart';
import 'package:migra_ayuda/core/utils/validators/password_validator.dart';

void main() {
  group('PasswordValidator Tests', () {
    test('Retorna error si la contraseña es nula o vacía', () {
      expect(PasswordValidator.validate(null), 'La contraseña es obligatoria');
      expect(PasswordValidator.validate(''), 'La contraseña es obligatoria');
      expect(PasswordValidator.validate('   '), 'La contraseña es obligatoria');
    });

    test('Retorna error si tiene menos de 8 caracteres', () {
      expect(PasswordValidator.validate('Abc1'), 'Debe tener al menos 8 caracteres');
      expect(PasswordValidator.validate('Abc1234'), 'Debe tener al menos 8 caracteres');
    });

    test('Retorna error si no contiene mayúsculas', () {
      expect(PasswordValidator.validate('abc12345'), 'Debe contener al menos una letra mayúscula');
    });

    test('Retorna error si no contiene minúsculas', () {
      expect(PasswordValidator.validate('ABC12345'), 'Debe contener al menos una letra minúscula');
    });

    test('Retorna error si no contiene números', () {
      expect(PasswordValidator.validate('Abcdefgh'), 'Debe contener al menos un número');
    });

    test('Retorna null (válido) si cumple con longitud >= 8, mayúscula, minúscula y número (sin exigir carácter especial)', () {
      expect(PasswordValidator.validate('Password123'), isNull);
      expect(PasswordValidator.validate('Segura99'), isNull);
      expect(PasswordValidator.validate('MigraAyuda2026'), isNull);
    });
  });
}
